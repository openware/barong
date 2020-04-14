# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over user api keys
      class APIKeys < Grape::API
        resource :api_keys do
          helpers ::API::V2::NamedParams
          helpers ::API::V2::Admin::NamedParams

          desc 'List all api keys for selected account.',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid, type: String, allow_blank: false, desc: 'user uniq id'
            use :pagination_filters
          end
          get do
            target_user = User.find_by(uid: params[:uid])
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            target_user.api_keys.tap { |q| present paginate(q), with: Entities::APIKey, except: [:secret] }
          end
        end
      end
    end
  end
end
