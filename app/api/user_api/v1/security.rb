# frozen_string_literal: true

module UserApi
  module V1
    class Security < Grape::API
      desc 'Security related routes'
      resource :security do
        desc 'Renews JWT if current JWT is valid'
        post '/renew' do
          Barong::Security::AccessToken.generate_jwt(account_uid: current_account.uid,
                                                     expires_in: params[:expires_in])
        end

        desc 'Generate qr code for 2FA'
        post '/generate_qrcode' do
          error!('You are already enabled 2FA', 400) if current_account.otp_enabled
          Vault::TOTP.create(current_account.uid, current_account.email)
        end

        desc 'Enable 2FA'
        params do
          requires :code, type: String, desc: 'Code from Google Authenticator',
                          allow_blank: false
        end
        post '/enable_2fa' do
          error!('You are already enabled 2FA', 400) if current_account.otp_enabled

          unless Vault::TOTP.validate?(current_account.uid, declared(params)[:code])
            error!('Your code is invalid', 422)
          end

          unless current_account.update(otp_enabled: true)
            error!(current_account.errors.full_messages.to_sentence, 422)
          end
        end

        desc 'Verify 2FA code'
        params do
          requires :code, type: String, desc: 'Code from Google Authenticator',
                          allow_blank: false
        end
        post '/verify_code' do
          error!('You need to enable 2FA first', 400) unless current_account.otp_enabled

          unless Vault::TOTP.validate?(current_account.uid, declared(params)[:code])
            error!('Your code is invalid', 422)
          end
        end

        desc 'Send reset password instructions'
        params do
          requires :email, type: String, desc: 'account email', allow_blank: false
        end
        post '/reset_password' do
          account = Account.find_by!(declared(params))
          account.send_reset_password_instructions

          if account.errors.any?
            error!(current_account.errors.full_messages.to_sentence, 422)
          end
        end

        desc 'Sets new account password'
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
      end
    end
  end
end
