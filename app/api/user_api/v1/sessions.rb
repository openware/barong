# frozen_string_literal: true

module UserApi
  module V1
    class Sessions < Grape::API
      helpers do
        def find_account!(email)
          account = Account.kept.find_by(email: email)
          error!('Invalid Email or password.', 401) unless account
          account
        end

        def find_application!(uid)
          application = Doorkeeper::Application.find_by(uid: uid)
          error!('Wrong application id', 401) unless application
          application
        end

        def create_token(application:, account:, expires_in:)
          Barong::Security::AccessToken.create expires_in, account.id, application
        end

        def handle_lockable(account)
          return unless account.lock_strategy_enabled?(:failed_attempts)
          account.unlock_access! if account.send :lock_expired?
          account.increment_failed_attempts

          if account.send :attempts_exceeded?
            account.lock_access! unless account.access_locked?
          else
            account.save(validate: false)
          end
        end

        def show_last_attempt_message(account)
          return unless account.lock_strategy_enabled?(:failed_attempts)
          return unless Account.last_attempt_warning

          if account.send(:last_attempt?)
            error!('You have one more attempt before your account is locked.', 401)
          end
        end

        def check_password_and_lock_status(account:, password:)
          unless account.valid_password?(password)
            handle_lockable(account)
            error!('Your account is locked.', 401) if account.access_locked?
            show_last_attempt_message(account)
            error!('Invalid Email or password.', 401)
          end

          unless account.active_for_authentication?
            error!(I18n.t(account.inactive_message, scope: 'devise.failure'), 401)
          end
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
        end

        post do
          declared_params = declared(params, include_missing: false)
          account = find_account!(declared_params[:email])
          application = find_application!(declared_params[:application_id])

          check_password_and_lock_status(account: account,
                                         password: declared_params[:password])

          create_token expires_in: declared_params[:expires_in],
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
