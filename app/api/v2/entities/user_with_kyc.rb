# frozen_string_literal: true

module API
  module V2
    module Entities
      # User information containing profile, labels and documents
      class UserWithKYC < API::V2::Entities::Base
        expose :email, documentation: { type: 'String' }
        expose :uid, documentation: { type: 'String' }
        expose :role, documentation: { type: 'String' }
        expose :level, documentation: { type: 'Integer' }
        expose :otp, documentation: { type: 'Boolean' }
        expose :state, documentation: { type: 'String' }
        expose :data, documentation: { type: 'String', desc: 'additional phone and profile info' }
        expose :profile, using: Entities::Profile
        expose :labels, using: Entities::AdminLabelView
        expose :phones, using: Entities::Phone
        expose :documents, using: Entities::Document
        expose :data_storages, using: Entities::DataStorage
        expose :referral_uid, documentation: { type: 'String', desc: 'UID of referrer' } do |user|
          user.referral_uid
        end
        # activities, as sensitive and potentialy too big data should be queried separately

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
