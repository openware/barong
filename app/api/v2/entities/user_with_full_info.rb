# frozen_string_literal: true

module API
  module V2
    module Entities
      # User information containing profile, labels and documents
      class UserWithFullInfo < Grape::Entity
        format_with(:iso_timestamp) { |d| d&.utc&.iso8601 }

        expose :email, documentation: { type: 'String' }
        expose :uid, documentation: { type: 'String' }
        expose :role, documentation: { type: 'String' }
        expose :level, documentation: { type: 'Integer' }
        expose :otp, documentation: { type: 'Boolean' }
        expose :state, documentation: { type: 'String' }
        expose :referral_uid, documentation: { type: 'String', desc: 'UID of referrer' } do |user|
          user.referral_uid
        end
        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end

        expose :labels, using: Entities::Label
        expose :phones, using: Entities::Phone
        expose :profile, using: Entities::Profile
        # activities, as sensitive and potentialy too big data should be queried separately
      end
    end
  end
end
