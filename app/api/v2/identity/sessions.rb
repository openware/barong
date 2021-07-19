# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Sessions < Grape::API
      helpers do
        def get_user(email)
          user = User.find_by(email: email)
          error!({ errors: ['identity.session.invalid_params'] }, 401) unless user

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'deleted'
            login_error!(reason: 'Your account is deleted', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'deleted')
          end

          # if user is not active or pending, then return 401
          unless user.state.in?(%w[active pending])
            login_error!(reason: 'Your account is not active', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'not_active')
          end
          user
        end
      end

      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          optional :captcha_response,
                   types: { value: [String, Hash], message: 'identity.session.invalid_captcha_format' },
                   desc: 'Response from captcha widget'
          optional :otp_code,
                   type: String,
                   desc: 'Code from Google Authenticator'
        end
        post do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('password')
          verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')

          declared_params = declared(params, include_missing: false)
          user = get_user(declared_params[:email])

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          unless user.otp
            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            csrf_token = open_session(user)
            publish_session_create(user)

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
            return status 200
          end

          error!({ errors: ['identity.session.missing_otp'] }, 401) if declared_params[:otp_code].blank?
          unless TOTPService.validate?(user.uid, declared_params[:otp_code])
            login_error!(reason: 'OTP code is invalid', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed', error_text: 'invalid_otp')
          end

          activity_record(user: user.id, action: 'login::2fa', result: 'succeed', topic: 'session')
          csrf_token = open_session(user)
          publish_session_create(user)

          present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          status(200)
        end

        desc 'Destroy current session',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
          ],
          success: { code: 200, message: 'Session was destroyed' }
        params do
          optional :auth_method,
                   type: String,
                   default: 'password',
                   values: { value: -> {  %w[password signature auth0] }, message: 'identity.session.invalid_auth_method' },
                   desc: 'Auth method'
        end
        delete do
          if params[:auth_method].in?['password','auth0']
            entity = User.find_by(uid: session[:uid])
            error!({ errors: ['identity.session.not_found'] }, 404) unless entity
            activity_record(user: entity.id, action: 'logout', result: 'succeed', topic: 'session')
          elsif params[:auth_method] == 'signature'
            entity = PublicAddress.find_by(uid: session[:uid])
            error!({ errors: ['identity.session.not_found'] }, 404) unless entity
          else
            error!({ errors: ['identity.session.not_found'] }, 404)
          end

          Barong::RedisSession.delete(entity.uid, session.id)
          session.destroy

          status(200)
        end

        desc 'Auth0 authentication by id_token',
             success: { code: 200, message: 'User authenticated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :id_token,
                   type: String,
                   allow_blank: false,
                   desc: 'ID Token'
        end
        post '/auth0' do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('auth0')

          begin
            # Decode ID token to get user info
            claims = Barong::Auth0::JWT.verify(params[:id_token]).first
            error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless claims.key?('email')
            user = User.find_by(email: claims['email'])

            # If there is no user in platform and user email verified from id_token
            # system will create user
            if user.blank? && claims['email_verified']
              user = User.create!(email: claims['email'], state: 'active')
              user.labels.create!(scope: 'private', key: 'email', value: 'verified')
            elsif claims['email_verified'] == false
              error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless user
            end

            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            csrf_token = open_session(user)
            publish_session_create(user)

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          rescue StandardError => e
            report_exception(e)
            error!({ errors: ['identity.session.auth0.invalid_params'] }, 422)
          end
        end

        desc 'Start session by signature',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
          ]
        params do
          requires :nickname, type: String, desc: -> { API::V2::Entities::PublicAddress.documentation[:address][:desc] }
          requires :nonce, type: String, desc: 'Auth Nonce'
          requires :signature, type: Integer, desc: 'Auth Signature'
          optional :captcha_response, type: String, desc: 'Response from captcha widget'
        end
        post '/signature' do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('signature')

          # 1 Manage errors
          signature = Barong::Signature.transform_signature(params[:nickname])
          # params[:signature] = "0x96d85e31444319bea6cf14af909e1c321f57aaaeb376426f5621d8047093724558b27d795655498b9f38ce8009620f9931f2d706507875c987da2f7afd539602"
          # signature = params[:signature]

          # ## u8aToU8a function body
          # value = signature.delete_prefix("0x")
          # valLength = value.length / 2
          # bufLength = valLength.ceil
          # array = Array.new(bufLength, 0)
          # offset = [0, bufLength - valLength].max
          # for i in (0...array.size)
          #   array[i + offset] = value.slice(i*2, 2).to_i(16)
          # end
          # ## end of function body

          # error!({ errors: ['identity.session.signature.invalid_signature_length'] }, 401) unless signature.length.include?[64, 65, 66]
          # signature = array.pack("C*")

          # decodeAddress
          # function body
          # TODO VALIDATE
          # base58 encode
          BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
          lol = BaseX.new(BASE58_ALPHABET)
          decoded = lol.decode(params[:nickname]).unpack("C*")
          allowed_encoded_lengths = [3, 4, 6, 10, 35, 36, 37, 38]
          error!({ errors: ['identity.session.signature.invalid_signature_length'] }, 401) unless decoded.length.in?allowed_encoded_lengths
          
          # checkAddressChecksum

          ss58Length = (decoded[0] & 0b0100_0000) == 0 ? 1 : 2
          second_choice = [((decoded[0] & 0b0011_1111) << 2) | (decoded[1] >> 6) | ((decoded[1] & 0b0011_1111) << 8)].pack("l").unpack("l").first
          ss58Decoded = ss58Length == 1 ? decoded[0] : second_choice
          isPublicKey = [34 + ss58Length, 35 + ss58Length].include?(decoded.length)
          length = decoded.length - (isPublicKey ? 2 : 1)

          # calculate the hash and do the checksum byte checks
          SS58_PREFIX = 'SS58PRE'
          hex_values = SS58_PREFIX.split('').collect { |char| "%2d" % [char.ord] }.map(&:to_i)

          u8uaConcat = hex_values.concat(decoded.slice(0, length))


          byteLength = (512 / 8).ceil

          key = Blake2b::Key.none
          input = u8uaConcat.pack('c*').force_encoding('UTF-8')
          hash = Blake2b.bytes(input, key, byteLength)

          isValid = (decoded[0] & 0b1000_0000) === 0 && ![46, 47].include?(decoded[0]) && isPublicKey ?
              decoded[decoded.length - 2] === hash[0] && decoded[decoded.length - 1] === hash[1] : decoded[decoded.length - 1] === hash[0]

          ## end of function body


          verify_key = Ed25519::VerifyKey.new(public_key)
          # here should be hashed message !!!
          message = "#" + params[:nickname] + "#" + params[:nonce]

          unless verify_key.verify(signature, message)
            error!({ errors: ['identity.session.signature.invalid_params'] }, 401)
          end

          public_address = PublicAddress.find_by(address: params[:nickname])
          unless public_address
            # With which level we should create public address?
            public_address = PublicAddress.create(address: params[:nickname], role: 'member')
          end

          csrf_token = open_session(public_address)

          present public_address, with: API::V2::Entities::PublicAddress, csrf_token: csrf_token
        end
      end
    end
  end
end
