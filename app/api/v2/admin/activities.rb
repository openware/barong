# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over activities table
      class Activities < Grape::API
        resource :activities do
          helpers ::API::V2::NamedParams
          helpers ::API::V2::Admin::NamedParams
          helpers do
            def permitted_search_params(params)
              params[:range] = 'created'
              params.slice(:action, :uid, :email, :topic, :from, :to, :range, :target_uid).merge(with_user: true, ordered: true)
            end
          end

          desc 'Returns array of activities as paginated collection',
               security: [{ "BearerToken": [] }],
               failure: [
                   { code: 401, message: 'Invalid bearer token' }
               ]
          params do
            use :activity_attributes
            use :timeperiod_filters
            use :pagination_filters
          end
          get do
            authorize! :read, Activity

            activities = API::V2::Queries::ActivityFilter.new(Activity.where(category: 'user')).call(permitted_search_params(params))
            activities.tap { |q| present paginate(q), with: API::V2::Entities::ActivityWithUser }
          end

          desc 'Returns array of activities as paginated collection',
          security: [{ "BearerToken": [] }],
          failure: [
              { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            use :activity_attributes
            use :timeperiod_filters
            use :pagination_filters
            optional :target_uid,
                     type: { value: String, message: 'admin.activity.non_string_target_uid' }
            optional :range,
                     type: String,
                     values: { value: -> (p){ %w[created].include?(p) }, message: 'admin.activity.invalid_range' },
                     default: 'created'
          end
          get '/admin' do
            authorize! :read, Activity

            activities = API::V2::Queries::ActivityFilter.new(Activity.where(category: 'admin')).call(permitted_search_params(params))
            activities.tap { |q| present paginate(q), with: API::V2::Entities::AdminActivity }
          end
        end
      end
    end
  end
end
