# frozen_string_literal: true

module Entities
  class Profile < Grape::Entity
    expose :first_name, documentation: { type: 'String' }
    expose :last_name, documentation: { type: 'String' }
    expose :dob, documentation: { type: 'Date', desc: 'Birthday date' }
    expose :address, documentation: { type: 'String' }
    expose :postcode, documentation: { type: 'String' }
    expose :city, documentation: { type: 'String' }
    expose :country, documentation: { type: 'String' }
    expose :metadata, documentation: { type: 'Hash', desc: 'Profile additional fields' }
  end
end
