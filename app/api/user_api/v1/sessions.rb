# frozen_string_literal: true

module UserApi
  module V1
    class Sessions < Grape::API
      helpers do
        def create_access_token(expires_in:, account:, application:)
          if expires_in.present? && (expires_in.to_i < 30.minutes.to_i \
             || expires_in.to_i >= 24.hours.to_i)
            error! "expires_in must be from #{30.minutes} to #{24.hours.to_i} seconds", 401
          end

          Barong::Security::AccessToken.create expires_in, account.id, application
        end
      end

      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          requires :application_id
          optional :expires_in, allow_blank: false
          optional :otp_code, type: String,
                              desc: 'Code from Google Authenticator'
        end

        post do
          declared_params = declared(params, include_missing: false)
          account = Account.kept.find_by(email: declared_params[:email])
          error!('Invalid Email or Password', 401) unless account

          application = Doorkeeper::Application.find_by(uid: declared_params[:application_id])
          error!('Wrong Application ID', 401) unless application
          error!('Your account was locked!', 401) unless account.locked_at.nil?

          unless account.valid_password? declared_params[:password]
            account.add_failed_attempt
            error!('Invalid Email or Password', 401)
          end

          unless account.active_for_authentication?
            error!('You have to confirm your email address before continuing', 401)
          end

          unless account.otp_enabled
            account.refresh_failed_attempts
            return create_access_token expires_in: declared_params[:expires_in],
                                       account: account,
                                       application: application
          end

          if declared_params[:otp_code].blank?
            account.add_failed_attempt
            error!('The account has enabled 2FA but OTP code is missing', 403)
          end

          unless Vault::TOTP.validate?(account.uid, declared_params[:otp_code])
            account.add_failed_attempt
            error!('OTP code is invalid', 403)
          end

          account.refresh_failed_attempts
          create_access_token expires_in: declared_params[:expires_in],
                              account: account,
                              application: application
        end

        desc 'Validates client jwt and generates peatio session jwt',
             success: { code: 200, message: 'Session is generated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'JWT is invalid' }
             ]
        params do
          requires :kid, type: String, allow_blank: false, desc: 'API Key uid'
          requires :jwt_token, type: String, allow_blank: false
        end
        post 'generate_jwt' do
          status 200
          declared_params = declared(params).symbolize_keys
          generator = SessionJWTGenerator.new declared_params
          error!('Payload is invalid', 401) unless generator.verify_payload

          { token: generator.generate_session_jwt }
        rescue JWT::DecodeError => e
          error! "Failed to decode and verify JWT: #{e.inspect}", 401
        end
      end
    end
  end
end
