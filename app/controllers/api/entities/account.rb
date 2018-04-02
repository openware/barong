module API
  module Entities
    class Account < Grape::Entity
      expose :uid
      expose :email
      expose :level
      expose :role
      expose :state
    end
  end
end