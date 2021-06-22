# frozen_string_literal: true

module API::V2
  module Entities
    class Profile < API::V2::Entities::Base
      expose :first_name,
             documentation: {
              type: 'String',
              desc: 'First Name'
             }

      expose :last_name,
             documentation: {
              type: 'String',
              desc: 'Submasked last name'
             } do |profile|
              Barong::App.config.api_data_masking_enabled ? profile.sub_masked_last_name : profile.last_name
             end

      expose :dob,
             documentation: {
              type: 'Date',
              desc: 'Submasked birth date'
             } do |profile|
              Barong::App.config.api_data_masking_enabled ? profile.sub_masked_dob : profile.dob
             end

      expose :address,
             documentation: {
              type: 'String',
              desc: 'Address'
             }

      expose :postcode,
             documentation: {
              type: 'String',
              desc: 'Address Postcode'
             }

      expose :city,
             documentation: {
              type: 'String',
              desc: 'City name'
             }

      expose :country,
             documentation: {
              type: 'String',
              desc: 'Country name'
             }

      expose :state,
             documentation: {
              type: 'String',
              desc: 'Profile state: drafted, submitted, verified, rejected'
             }

      expose :metadata,
             documentation: {
              type: 'Hash',
              desc: 'Profile additional fields'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
