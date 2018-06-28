# frozen_string_literal: true

module Services
  class AuthService
    class Error < Grape::Exceptions::Base; end

    class << self
      def sign_in(params:, device_uid:)
        @account = find_account!(params)
        @application = find_application!(params)
        @device = @account.devices.find_by(uid: device_uid)

        unless check_for_otp?
          device = update_or_create_device!(remember_me: params[:remember_me])
          @account.refresh_failed_attempts
          return {
            token: create_access_token(expires_in: params[:expires_in]),
            device_uid: device.try(:uid)
          }
        end

        check_otp!(code: params[:otp_code])
        device = update_or_create_device!(remember_me: params[:remember_me],
                                          otp: true)
        @account.refresh_failed_attempts

        {
          token: create_access_token(expires_in: params[:expires_in]),
          device_uid: device.try(:uid)
        }
      end

    private

      def create_access_token(expires_in:)
        Barong::Security::AccessToken.create expires_in, @account.id, @application
      end

      def check_for_otp?
        return false unless @account.otp_enabled
        return true unless @device&.check_otp_time
        Time.current > @device&.check_otp_time
      end

      def check_otp!(code:)
        if code.blank?
          @account.add_failed_attempt
          error!('The account has enabled 2FA but OTP code is missing', 403)
        end

        return if Vault::TOTP.validate?(@account.uid, code)
        @account.add_failed_attempt
        error!('OTP code is invalid', 403)
      end

      def update_or_create_device!(remember_me:, otp: false)
        device_params = {
          last_sign_in: Time.current
        }
        device_params[:check_otp_time] = 30.days.from_now if otp
        return @device&.update!(device_params) if @device
        return unless remember_me
        @account.devices.create!(device_params)
      end

      def find_account!(params)
        account = Account.kept.find_by(email: params[:email])
        error!('Invalid Email or Password', 401) unless account
        error!('Your account was locked!', 401) if account.locked_at

        unless account.valid_password? params[:password]
          account.add_failed_attempt
          error!('Invalid Email or Password', 401)
        end

        unless account.active_for_authentication?
          error!('You have to confirm your email address before continuing', 401)
        end

        account
      end

      def find_application!(params)
        application = Doorkeeper::Application.find_by(uid: params[:application_id])
        application ? application : error!('Wrong Application ID', 401)
      end

      def error!(message, status)
        raise Error.new message: message, status: status
      end
    end
  end
end
