# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class UserWithProfile < API::V2::Entities::UserWithProfile
      expose :profiles, using: Entities::Profile
    end
  end
end
