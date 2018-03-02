# frozen_string_literal: true

module API
  module V1
    module Entities
      class Profile < Grape::Entity
        expose :first_name, documentation: { type: 'string', desc: 'First name for profile' }
        expose :last_name,  documentation: { type: 'string', desc: 'Last name for profile' }
        expose :dob,        documentation: { type: 'string', desc: 'Date of birth for profile' }
        expose :address,    documentation: { type: 'string', desc: 'Address for profile' }
        expose :postcode,   documentation: { type: 'string', desc: 'Postcode for profile' }
        expose :city,       documentation: { type: 'string', desc: 'City for profile' }
        expose :country,    documentation: { type: 'string', desc: 'Country for profile' }
      end
    end
  end
end
