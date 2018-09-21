# frozen_string_literal: true

require 'barong/security/access_token'

module UserApi
  module V1
    class Security < Grape::API
      desc 'Security related routes'
      resource :security do
        desc 'Renews JWT if current JWT is valid',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Invalid expires_in' }
             ]
        params do
          optional :expires_in, type: String, desc: 'Expires in time in seconds',
                                allow_blank: false
        end
        post '/renew' do
          if params[:expires_in].present? && (params[:expires_in].to_i < 30.minutes \
             || params[:expires_in].to_i > 24.hours.to_i)
            error! "expires_in must be from #{30.minutes} to #{24.hours.to_i} seconds", 422
          end

          # expiration time will be specified by the request param or taken from ENV, if both are nil, it will be 4 hours
          Barong::Security::AccessToken.create params[:expires_in],
                                               current_account.id,
                                               current_application
        end

        desc 'Generate qr code for 2FA',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: '2FA has been enabled for this account' },
               { code: 401, message: 'Invalid bearer token' }
             ]
        post '/generate_qrcode' do
          error!('2FA has been enabled for this account', 400) if current_account.otp_enabled
          Vault::TOTP.create(current_account.uid, current_account.email)
        end

        desc 'Enable 2FA',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: '2FA has been enabled for this account or code is missing' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :code, type: String, desc: 'Code from Google Authenticator',
                          allow_blank: false
        end
        post '/enable_2fa' do
          error!('2FA has been enabled for this account', 400) if current_account.otp_enabled

          unless Vault::TOTP.validate?(current_account.uid, declared(params)[:code])
            error!('OTP code is invalid', 422)
          end

          unless current_account.update(otp_enabled: true)
            error!(current_account.errors.full_messages.to_sentence, 422)
          end
        end

        desc 'Verify 2FA code',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: '2FA has not been enabled for this account or code is missing' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :code, type: String, desc: 'Code from Google Authenticator',
                          allow_blank: false
        end
        post '/verify_code' do
          error!('2FA has not been enabled for this account', 400) unless current_account.otp_enabled

          unless Vault::TOTP.validate?(current_account.uid, declared(params)[:code])
            error!('OTP code is invalid', 422)
          end
        end

        desc 'Send reset password instructions',
             failure: [
               { code: 400, message: 'Email is missing' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :email, type: String, desc: 'account email', allow_blank: false
        end
        post '/reset_password' do
          account = Account.kept.find_by!(declared(params))
          account.send_reset_password_instructions

          if account.errors.any?
            error!(current_account.errors.full_messages.to_sentence, 422)
          end
        end

        desc 'Sets new account password',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :reset_password_token, type: String,
                                          desc: 'Token from email',
                                          allow_blank: false
          requires :password, type: String,
                              desc: 'Account password',
                              allow_blank: false
        end
        put '/reset_password' do
          required_params = declared(params)
                            .merge(password_confirmation: params[:password])

          account = Account.reset_password_by_token(required_params)
          raise ActiveRecord::RecordNotFound unless account.persisted?

          if account.errors.any?
            error!(account.errors.full_messages.to_sentence, 422)
          end
        end

        desc 'Verify API key',
             security: [{ "BearerToken": [] }],
             success: { code: 200, message: 'API key is valid' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :uid, type: String, desc: 'API Key uid', allow_blank: false
          optional :account_uid, type: String, desc: 'Account uid', allow_blank: false
        end
        post '/verify_api_key' do
          status 200
          api_key = APIKey.find_by!(uid: params[:uid])

          if params[:account_uid].present? && api_key.account.uid != params[:account_uid]
            error!('Account has no api key with provided uid', 422)
          end

          { state: api_key.state }
        end
      end
    end
  end
end
