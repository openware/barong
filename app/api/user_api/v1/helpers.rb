# frozen_string_literal: true

module UserApi
  module V1
    module Helpers
      def current_account
        @current_account ||= begin
          Account.find_by(uid: env['user_api.v1.current_account_uid'])
        end

        @current_account or raise AuthorizationError
      end

      def phone_valid?(phone_number)
        phone_number = PhoneUtils.sanitize(phone_number)

        unless PhoneUtils.valid?(phone_number)
          error!('Phone number is invalid', 400)
          return false
        end

        if Phone.verified.exists?(number: phone_number)
          error!('Phone number is already exists', 400)
          return false
        end
        true
      end
    end
  end
end
