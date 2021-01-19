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
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Entities::APIKey
          params do
            requires :uid, type: String, allow_blank: false, desc: 'user uniq id'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'api_keys.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     values: { value: -> (p){ APIKey.new.attributes.keys.include?(p) }, message: 'api_keys.ordering.invalid_attribute' },
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, APIKey

            target_user = User.find_by(uid: params[:uid])
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            target_user.api_keys.order(params[:order_by] => params[:ordering]).tap { |q| present paginate(q), with: API::V2::Entities::APIKey, except: [:secret] }
          end
        end
      end
    end
  end
end
