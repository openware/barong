# frozen_string_literal: true

require 'barong/security/access_token'

module ManagementAPI
  module V1
    class OTP < Grape::API
      helpers do
        def sign_request(jwt)
          JWT::Multisig.add_jws(jwt, :barong, Barong::Security.private_key, 'RS256')
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
          requires :account_uid, type: String, allow_blank: false, desc: 'Account UID'
          requires :otp_code, type: String, allow_blank: false, desc: 'Code from Google Authenticator'
          requires :jwt, type: Hash, allow_blank: false, desc: 'RFC 7516 jwt with applogic signature'
        end
        post '/sign' do
          declared_params = declared(params)
          account = Account.kept.active.find_by!(uid: declared_params[:account_uid])
          error!('Account has not enabled 2FA', 422) unless account.otp_enabled?

          unless Vault::TOTP.validate?(account.uid, declared_params[:otp_code])
            error!('OTP code is invalid', 422)
          end

          sign_request(declared_params[:jwt])
        end
      end
    end
  end
end
