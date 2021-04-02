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
          failure: [
            { code: 400, message: '2FA has been enabled for this account' },
            { code: 401, message: 'Invalid bearer token' }
          ],
          success: { code: 200, message: 'QR code was generated' }
        post '/generate_qrcode' do
          if current_user.otp
            otp_error!(reason: '2FA has been already enabled for this account', error_code: 400,
              user: current_user.id, action: 'request QR code for 2FA', error_text: 'already_enabled')
          end

          activity_record(user: current_user.id, action: 'request QR code for 2FA', result: 'succeed', topic: 'otp')
          TOTPService.create(current_user.uid, current_user.email)
        end

        desc 'Enable 2FA',
          failure: [
            { code: 400, message: '2FA has been enabled for this account or code is missing' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ],
          success: { code: 200, message: '2FA was enabled' }
        params do
          requires :code,
                   type: String,
                   allow_blank: false,
                   desc: 'Code from Google Authenticator'
        end
        post '/enable' do
          if current_user.otp
            otp_error!(reason: '2FA has been already enabled for this account', error_code: 400,
                         user: current_user.id, action: 'enable 2FA', error_text: 'already_enabled')
          end

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            otp_error!(reason: 'OTP code is invalid', error_code: 422,
              user: current_user.id, action: 'enable 2FA', error_text: 'invalid')
          end

          unless current_user.update(otp: true)
            # FIXME active record validation
            otp_error!(reason: current_user.errors.full_messages.to_sentence, error_code: 422,
              user: current_user.id, action: 'enable 2FA')
          end

          current_user.labels.create(key: :otp, value: :enabled, scope: :private) unless current_user.labels.find_by(key: :otp, scope: :private)
          activity_record(user: current_user.id, action: 'enable 2FA', result: 'succeed', topic: 'otp')

          # Invalidate all user session except current
          Barong::RedisSession.invalidate_all(current_user.uid, request.session.id.to_s)
          200
        end

        desc 'Disable 2FA',
          failure: [
            { code: 400, message: '2FA has not been enabled for this account or code is missing' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ],
          success: { code: 200, message: '2FA was disabled' }
        params do
          requires :code,
                   type: String,
                   allow_blank: false,
                   desc: 'Code from Google Authenticator'
        end
        post '/disable' do
          unless current_user.otp
            otp_error!(reason: '2FA has not been enabled for this account', error_code: 400,
                       user: current_user.id, action: 'disable 2FA', error_text: 'not_enabled')
          end

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            otp_error!(reason: 'OTP code is invalid', error_code: 422,
                       user: current_user.id, action: 'disable 2FA', error_text: 'invalid')
          end

          unless current_user.update(otp: false)
            otp_error!(reason: current_user.errors.full_messages.to_sentence, error_code: 422,
              user: current_user.id, action: 'disable 2FA')
          end

          current_user.labels.find_by(key: :otp, scope: :private).delete if current_user.labels.find_by(key: :otp, scope: :private)
          activity_record(user: current_user.id, action: 'disable 2FA', result: 'succeed', topic: 'otp')

          status 200
        end

        desc 'Verify 2FA code',
          failure: [
            { code: 400, message: '2FA has not been enabled for this account or code is missing' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ],
          success: { code: 200, message: '2FA was verified' }
        params do
          requires :code,
                   type: String,
                   allow_blank: false,
                   desc: 'Code from Google Authenticator'
        end
        post '/verify' do
          unless current_user.otp
            otp_error!(reason: '2FA has not been enabled for this account', error_code: 400,
                       user: current_user.id, action: 'verify 2FA code', error_text: 'already_enabled')
          end

          unless TOTPService.validate?(current_user.uid, declared(params)[:code])
            otp_error!(reason: 'OTP code is invalid', error_code: 422,
                       user: current_user.id, action: 'verify 2FA code', error_text: 'invalid')
          end
        end
      end
    end
  end
end
