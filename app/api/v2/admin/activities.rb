# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over activities table
      class Activities < Grape::API
        helpers do
          def permitted_search_params(params)
            params[:range] = 'created'
            params.slice(:action, :uid, :email, :topic, :from, :to, :range, :target_uid).merge(with_user: true, ordered: true)
          end
        end

        resource :activities do
          desc 'Returns array of activities as paginated collection',
               security: [{ "BearerToken": [] }],
               failure: [
                   { code: 401, message: 'Invalid bearer token' }
               ]
          params do
            optional :topic,
                     type: { value: String, message: 'admin.activity.non_string_topic' }
            optional :action,
                     type: { value: String, message: 'admin.activity.non_string_action' }
            optional :uid,
                     type: { value: String, message: 'admin.activity.non_string_uid' }
            optional :email,
                     type: { value: String, message: 'admin.activity.non_string_email' }
            optional :from
            optional :to
            optional :page,
                     type: { value: Integer, message: 'admin.activity.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'admin.activity.non_positive_page'},
                     default: 1,
                     desc: 'Page number (defaults to 1).'
            optional :limit,
                     type: { value: Integer, message: 'admin.activity.non_integer_limit' },
                     values: { value: 1..100, message: 'admin.activity.invalid_limit' },
                     default: 100,
                     desc: 'Number of users per page (defaults to 100, maximum is 100).'
          end
          get do
            activities = API::V2::Queries::ActivityFilter.new(Activity.where(category: 'user')).call(permitted_search_params(params))
            activities.tap { |q| present paginate(q), with: API::V2::Entities::ActivityWithUser }
          end

          desc 'Returns array of activities as paginated collection',
          security: [{ "BearerToken": [] }],
          failure: [
              { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :topic,
                     type: { value: String, message: 'admin.activity.non_string_topic' }
            optional :action,
                     type: { value: String, message: 'admin.activity.non_string_action' }
            optional :uid,
                     type: { value: String, message: 'admin.activity.non_string_uid' }
            optional :email,
                     type: { value: String, message: 'admin.activity.non_string_email' }
            optional :target_uid,
                     type: { value: String, message: 'admin.activity.non_string_target_uid' }
            optional :range,
                     type: String,
                     values: { value: -> (p){ %w[created].include?(p) }, message: 'admin.user.invalid_range' },
                     default: 'created'
            optional :from
            optional :to
            optional :page,
                     type: { value: Integer, message: 'admin.activity.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'admin.activity.non_positive_page'},
                     default: 1,
                     desc: 'Page number (defaults to 1).'
            optional :limit,
                     type: { value: Integer, message: 'admin.activity.non_integer_limit' },
                     values: { value: 1..100, message: 'admin.activity.invalid_limit' },
                     default: 100,
                     desc: 'Number of users per page (defaults to 100, maximum is 100).'
          end
          get '/admin' do
            activities = API::V2::Queries::ActivityFilter.new(Activity.where(category: 'admin')).call(permitted_search_params(params))
            activities.tap { |q| present paginate(q), with: API::V2::Entities::AdminActivity }
          end
        end
      end
    end
  end
end
