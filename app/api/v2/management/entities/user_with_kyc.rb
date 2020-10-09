# frozen_string_literal: true

module API::V2::Management
  module Entities
    class UserWithKYC < API::V2::Entities::UserWithKYC
      expose :profiles, using: Entities::Profile
      expose :phones, using: Entities::Phone
      expose :documents, using: Entities::Document
    end
  end
end
