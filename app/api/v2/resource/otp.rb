# frozen_string_literal: true

module API::V2
  module Resource
    class Otp < Grape::API

      resource :otp do

        desc 'Generate qr code for 2FA',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: '2FA has been enabled for this account' },
               { code: 401, message: 'Invalid bearer token' }
             ]
        post '/generate_qrcode' do
          error!('2FA has been enabled for this account', 400) if current_user.otp
          TOTPService.create(current_user.uid, current_user.email)
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
        post '/enable' do
          error!('2FA has been enabled for this account', 400) if current_user.otp

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            error!('OTP code is invalid', 422)
          end

          unless current_user.update(otp: true)
            error!(current_user.errors.full_messages.to_sentence, 422)
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
        post '/verify' do
          error!('2FA has not been enabled for this account', 400) unless current_user.otp

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            error!('OTP code is invalid', 422)
          end
        end
      end
    end
  end
end
