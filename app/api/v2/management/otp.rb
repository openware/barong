# frozen_string_literal: true

module API
  module V2
    module Management
      class Otp < Grape::API
        helpers do
          def sign_request(jwt)
            JWT::Multisig.add_jws(jwt, :barong, Barong::App.config.keystore.private_key, 'RS256')
          rescue StandardError => e
            error!("JWT is invalid by the reason \"#{e.message}\"", 422)
          end
        end

        desc 'OTP related routes'
        resource :otp do
          desc 'Sign request with barong signature' do
            @settings[:scope] = :otp_sign
          end
          params do
            requires :user_uid, type: String, allow_blank: false, desc: 'Account UID'
            requires :otp_code, type: String, allow_blank: false, desc: 'Code from Google Authenticator'
            requires :jwt, type: Hash, allow_blank: false, desc: 'RFC 7516 jwt with applogic signature'
          end
          post '/sign' do
            declared_params = declared(params)
            user = User.active.find_by!(uid: declared_params[:user_uid])
            error!('Account has not enabled 2FA', 422) unless user.otp

            unless TOTPService.validate?(user.uid, declared_params[:otp_code])
              error!('OTP code is invalid', 422)
            end

            sign_request(declared_params[:jwt])
          end
        end
      end
    end
  end
end
