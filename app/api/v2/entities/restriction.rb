# frozen_string_literal: true

module API::V2
  module Entities
    class Restriction < API::V2::Entities::Base
      expose :id,
      documentation: {
        type: 'Integer',
        desc: 'Restriction id'
      }

      expose :category,
             documentation: {
               type: 'String',
               desc: 'Restriction categories: blacklist, maintenance, whitelist, blocklogin'
             }

      expose :scope,
             documentation: {
               type: 'String',
               desc: 'Restriction scopes: continent, country, ip, ip_subnet, all'
             }

      expose :value,
             documentation: {
               type: 'String',
               desc: 'Restriction value: IP address, country abbreviation, all'
             }

      expose :code,
             documentation: {
               type: 'Integer',
               desc: "Restriction codes: #{::Restriction::DEFAULT_CODES}"
             }

      expose :state,
             documentation: {
               type: 'String',
               desc: 'Restriction states: disabled, enabled'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
