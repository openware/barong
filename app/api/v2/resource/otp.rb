# frozen_string_literal: true

module API::V2
  module Resource
    # TOTP functionality API
    class Otp < Grape::API
      helpers do
        def otp_error!(options = {})
          options[:topic] = 'otp'
          record_error!(options)
        end
      end

      resource :otp do
        desc 'Generate qr code for 2FA',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: '2FA has been enabled for this account' },
               { code: 401, message: 'Invalid bearer token' }
             ]
        post '/generate_qrcode' do
          if current_user.otp
            otp_error!(reason: '2FA has been already enabled for this account', error_code: 400,
              user: current_user.id, action: 'request QR code for 2FA')
          end

          TOTPService.create(current_user.uid, current_user.email)
          activity_record(user: current_user.id, action: 'request QR code for 2FA', result: 'succeed', topic: 'otp')
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
          if current_user.otp
            otp_error!(reason: '2FA has been already enabled for this account', error_code: 400,
                         user: current_user.id, action: 'enable 2FA')
          end

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            otp_error!(reason: 'OTP code is invalid', error_code: 422,
              user: current_user.id, action: 'enable 2FA')
          end

          unless current_user.update(otp: true)
            otp_error!(reason: current_user.errors.full_messages.to_sentence, error_code: 422,
              user: current_user.id, action: 'enable 2FA')
          end

          activity_record(user: current_user.id, action: 'enable 2FA', result: 'succeed', topic: 'otp')
          200
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
          unless current_user.otp
            otp_error!(reason: '2FA has not been enabled for this account', error_code: 400,
                       user: current_user.id, action: 'verify 2FA code')
          end

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            otp_error!(reason: 'OTP code is invalid', error_code: 422,
                       user: current_user.id, action: 'verify 2FA code')
          end
        end
      end
    end
  end
end
