# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module UserApi
  module V1
    module Helpers
      include Doorkeeper::Grape::Helpers
      extend Memoist

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
      memoize :current_account

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

      def create_device!(action:, result:, otp: false, account: current_account)
        matched_device = account.devices.find_by uuid: env['device_uuid']

        account.devices.create!(
          env['device_params'].merge(
            action: action,
            result: result,
            uuid: matched_device&.uuid,
            otp: otp,
            expire_at: matched_device&.expire_at
          )
        )
      end
    end
  end
end
