# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module UserApi
  module V1
    module Helpers
      include Doorkeeper::Grape::Helpers

      def authorize!
        doorkeeper_authorize!
        error!('Unauthorized', 401) if token_blacklisted?(doorkeeper_token.token)
      end

      def current_account
        @current_account ||= begin
          authorize!
          Account.kept
                 .find_by(id: doorkeeper_token.resource_owner_id)
                 .tap do |account|
            error!('Account does not exist', 401) unless account
          end
        end
      end

      def current_application
        authorize! unless doorkeeper_token
        doorkeeper_token.application
      end

      def token_blacklisted?(token)
        Barong::Security::AccessToken.blacklisted?(token)
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
    end
  end
end
