# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over levels table
      class Levels < Grape::API
        resource :levels do
          desc 'Returns array of permissions as paginated collection',
          security: [{ 'BearerToken': [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          get do
            admin_authorize! :read, Level

            present Level.all, with: API::V2::Entities::Level
          end
        end
      end
    end
  end
end
