# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    module Helpers
      include Doorkeeper::Grape::Helpers

      def current_account
        @current_account ||= begin
          doorkeeper_authorize!
          Account.find(doorkeeper_token.resource_owner_id)
        end
      end

      def current_application
        doorkeeper_authorize! unless doorkeeper_token
        doorkeeper_token.application
      end

      def phone_valid?(phone_number)
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
