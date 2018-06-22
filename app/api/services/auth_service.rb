# frozen_string_literal: true

module Services
  class AuthService
    class Error < Grape::Exceptions::Base; end

    class << self
      def sign_in(params:, device_params:, device_uuid:)
        @device_params = device_params
        find_account!(params)
        find_application!(params)
        @matched_device = @account.devices.find_by(uuid: device_uuid)
        return create_session(params: params) unless check_for_otp?

        check_otp!(code: params[:otp_code])
        create_session(params: params, otp: true)
      end

    private

      def create_session(params:, otp: false)
        @account.refresh_failed_attempts
        device = create_device!(result: 'success', otp: otp)
        session = {
          token: create_access_token(expires_in: params[:expires_in])
        }
        session[:device_uuid] = device.uuid if params[:remember_me]
        session
      end

      def create_access_token(expires_in:)
        Barong::Security::AccessToken.create expires_in, @account.id, @application
      end

      def check_for_otp?
        return false unless @account.otp_enabled
        return true unless @device&.expire_at
        Time.current > @device&.expire_at
      end

      def check_otp!(code:)
        if code.blank?
          @account.add_failed_attempt
          create_device!(result: { error: { otp_code: :missing } }, otp: true)
          error!('The account has enabled 2FA but OTP code is missing', 403)
        end

        return if Vault::TOTP.validate?(@account.uid, code)
        @account.add_failed_attempt
        create_device!(result: { error: { otp_code: :invalid } }, otp: true)
        error!('OTP code is invalid', 403)
      end

      def find_account!(params)
        @account = Account.kept.find_by(email: params[:email])
        error!('Invalid Email or Password', 401) unless @account
        check_account_permissions!(password: params[:password])
      end

      def check_account_permissions!(password:)
        if @account.locked_at
          create_device!(result: { error: { account: :locked } })
          error!('Your account was locked!', 401)
        end

        unless @account.valid_password?(password)
          @account.add_failed_attempt
          create_device!(result: { error: { password: :invalid } })
          error!('Invalid Email or Password', 401)
        end

        return if @account.active_for_authentication?
        create_device!(result: { error: { email: :unconfirmed } })
        error!('You have to confirm your email address before continuing', 401)
      end

      def find_application!(params)
        @application = Doorkeeper::Application.find_by(uid: params[:application_id])
        @application || error!('Wrong Application ID', 401)
      end

      def create_device!(action: 'sign_in', result:, otp: false)
        @account.devices.create!(
          @device_params.merge(
            action: action,
            result: result,
            uuid: @matched_device&.uuid,
            otp: otp,
            expire_at: @matched_device&.expire_at
          )
        )
      end

      def error!(message, status)
        raise Error.new message: message, status: status
      end
    end
  end
end
