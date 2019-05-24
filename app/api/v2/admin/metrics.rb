# frozen_string_literal: true

module API
  module V2
    module Admin
      # Metrics functionality
      class Metrics < Grape::API
        helpers do
          def permitted_search_params(params)
            params.slice(:created_from, :created_to, :topic, :action, :result).merge(with_user: false)
          end
        end

        resource :metrics do
          desc 'Returns main statistic in the given time period',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :created_from
            optional :created_to
          end
          get do
            result = {}

            signup = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'account', action: 'signup', result: 'succeed'))
            )
            sucessful_login = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'session', action: 'login', result: 'succeed'))
            )
            failed_login = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'session', action: 'login', result: 'failed'))
            )

            result[:signups] = signup.group('date(created_at)').size
            result[:sucessful_logins] = sucessful_login.group('date(created_at)').size
            result[:failed_logins] = failed_login.group('date(created_at)').size

            result[:pending_applications] = Label.where({ key: 'document', value: 'pending', scope: 'private' }).count

            present result
          end
        end
      end
    end
  end
end
