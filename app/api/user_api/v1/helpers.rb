# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module UserApi
  module V1
    module Helpers
      include Doorkeeper::Grape::Helpers

      def warden
        env['warden']
      end

      def warden_account
        @warden_account ||= warden.authenticate(scope: :account)
      end

      def current_account
        @current_account ||= begin
          doorkeeper_authorize!
          Account.kept
                 .find_by(id: doorkeeper_token.resource_owner_id)
                 .tap do |account|
            error!('Account does not exist', 401) unless account
          end
        end
      end

      def current_application
        doorkeeper_authorize! unless doorkeeper_token
        doorkeeper_token.application
      end

      def phone_valid?(phone_number)
        phone_number = PhoneUtils.international(phone_number)

        unless PhoneUtils.valid?(phone_number)
          error!('Phone number is invalid', 400)
          return false
        end

        if Phone.verified.exists?(number: phone_number)
          error!('Phone number already exists', 400)
          return false
        end
        true
      end

      def verify_captcha_if_enabled!(account:, response:, error_statuses: [400, 422])
        return unless ENV['CAPTCHA_ENABLED'] == 'true'

        captcha_error_message = 'reCAPTCHA verification failed, please try again.'
        error!('recaptcha_response is required', error_statuses.first) if response.blank?
        return if RecaptchaVerifier.new(request: request).verify_recaptcha(model: account,
                                                                           skip_remote_ip: true,
                                                                           response: response)
        error!(captcha_error_message, error_statuses.last)
      rescue StandardError
        error!(captcha_error_message, error_statuses.last)
      end
    end
  end
end
