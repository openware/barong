# frozen_string_literal: true

module UserApi
  module V1
    module Helpers
      def warden
        env['warden']
      end

      def warden_account
        @warden_account ||= warden.authenticate(scope: :account)
      end

      def current_account
        @current_account ||= begin
          if headers['Authorization'].blank?
            error!('Authorization is required', 401)
          end

          token = headers['Authorization'].split(' ').last
          payload, _ = jwt_decode(token)

          Account.kept.find_by(uid: payload['uid']).tap do |account|
            error!('Account does not exist', 401) unless account
          end
        end
      end

      def jwt_decode(token)
        options = {
          verify_expiration: true,
          verify_iat: true,
          verify_jti: true,
          sub: 'session',
          verify_sub: true,
          iss: 'barong',
          verify_iss: true,
          algorithm: 'RS256'
        }.freeze

        JWT.decode(token, Barong::Security.public_key, true, options)
      rescue StandardError => e
        Rails.logger.error "JWT is invalid: #{e.inspect}"
        error!('JWT is invalid', 401)
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
