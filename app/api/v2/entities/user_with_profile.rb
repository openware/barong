# frozen_string_literal: true

module API::V2
  module Entities
    class UserWithProfile < Grape::Entity
      format_with(:iso_timestamp) { |d| d&.utc&.iso8601 }

      expose :email, documentation: { type: 'String' }
      expose :uid, documentation: { type: 'String' }
      expose :role, documentation: { type: 'String' }
      expose :level, documentation: { type: 'Integer' }
      expose :otp, documentation: { type: 'Boolean', desc: 'is 2FA enabled for account' }
      expose :state, documentation: { type: 'String' }
      expose :profile, using: Entities::Profile
      expose :referral_uid, documentation: { type: 'String', desc: 'UID of referrer' } do |user|
        user.referral_uid
      end

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
