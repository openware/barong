# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
require 'barong/security/access_token'

module API
  module V1
    class Security < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account
          @current_account ||= Account.find(doorkeeper_token.resource_owner_id)
        end

        def current_application
          doorkeeper_token.application
        end

        def with_vault_error_handler
          yield
        rescue Vault::VaultError => error
          error_message = error.message
          Rails.logger.error "#{error.class}: #{error_message}"
          error!(error_message, 500)
        end
      end

      desc 'Security related routes'
      resource :security do
        desc 'Renews JWT if current JWT is valid'
        post '/renew' do
          # expiration time will be specified by the request param or taken from ENV, if both are nil, it will be 4 hours
          Barong::Security::AccessToken.create params[:expires_in],
                                               current_account.id,
                                               current_application
        end

        desc 'Generate qr code for 2FA'
        post '/generate_qrcode' do
          with_vault_error_handler do
            error!('You are already enabled 2FA', 400) if current_account.otp_enabled
            Vault::TOTP.safe_create(current_account.uid, current_account.email)
          end
        end

        desc 'Enable 2FA'
        params do
          requires :code, type: String, desc: 'Code from Google Authenticator',
                          allow_blank: false
        end
        post '/enable_2fa' do
          with_vault_error_handler do
            error!('You are already enabled 2FA', 400) if current_account.otp_enabled

            unless Vault::TOTP.validate?(current_account.uid, declared(params)[:code])
              error!('Your code is invalid', 422)
            end

            unless current_account.update(otp_enabled: true)
              error!(current_account.errors.full_messages.to_sentence, 422)
            end
          end
        end

        desc 'Verify 2FA code'
        params do
          requires :code, type: String, desc: 'Code from Google Authenticator',
                          allow_blank: false
        end
        post '/verify_code' do
          with_vault_error_handler do
            error!('You need to enable 2FA first', 400) unless current_account.otp_enabled

            unless Vault::TOTP.validate?(current_account.uid, declared(params)[:code])
              error!('Your code is invalid', 422)
            end
          end
        end
      end
    end
  end
end
