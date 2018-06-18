# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module UserApi
  module V1
    module Helpers
      include Doorkeeper::Grape::Helpers

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

      def create_device_activity!(account_id:, status:, action: 'sign_in')
        DeviceActivity.create!(
          env['user_device_activity'].merge(
            action: action,
            status: status,
            account_id: account_id
          )
        )
        previous_ip = DeviceActivity.where(account_id: account_id).last&.user_ip
        return unless action == 'sign_in'

        if previous_ip && previous_ip != env['user_device_activity'][:user_ip]
          EventAPI.notify('system.session.different_ip',
            old_ip: previous_ip,
            new_ip: env['user_device_activity'][:user_ip])
        end
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
