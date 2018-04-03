# frozen_string_literal: true

module API::V1::Entities
  class Profile < Grape::Entity
    expose :first_name, documentation: { desc: 'First name' }
    expose :last_name,  documentation: { desc: 'Last name' }
    expose :dob,        documentation: { desc: 'Date of birth' }
    expose :address,    documentation: { desc: 'Address' }
    expose :city,       documentation: { desc: 'City' }
    expose :country,    documentation: { desc: 'Country' }
    expose :state,      documentation: { desc: 'State of profile, can be pending, created, approved, rejected' }
  end
end
