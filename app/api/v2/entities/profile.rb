# frozen_string_literal: true

module API::V2
  module Entities
    class Profile < API::V2::Entities::Base
      expose :first_name, documentation: { type: 'String' }
      expose :last_name, documentation: { type: 'String', desc: 'Submasked last name' } do |profile|
        Barong::App.config.api_data_masking_enabled ? profile.sub_masked_last_name : profile.last_name
      end
      expose :dob, documentation: { type: 'Date', desc: 'Submasked birthday date' } do |profile|
        Barong::App.config.api_data_masking_enabled ? profile.sub_masked_dob : profile.dob
      end
      expose :address, documentation: { type: 'String' }
      expose :postcode, documentation: { type: 'String' }
      expose :city, documentation: { type: 'String' }
      expose :country, documentation: { type: 'String' }
      expose :state, documentation: { type: 'String' }
      expose :metadata, documentation: { type: 'Hash', desc: 'Profile additional fields' }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
