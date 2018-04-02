module API
  module Entities
    class Profile < Grape::Entity
      expose :first_name
      expose :last_name
      expose :dob
      expose :address
      expose :city
      expose :country
      expose :state
    end
  end
end