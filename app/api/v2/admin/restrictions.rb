# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over restrictions table
      class Restrictions < Grape::API
        resource :restrictions do
          helpers ::API::V2::NamedParams

          desc 'Returns array of restrictions as a paginated collection',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Entities::Restriction
          params do
            optional :scope,
                     allow_blank: false,
                     values: { value: -> { Restriction::SCOPES }, message: 'admin.restriction.invalid_scope'}
            optional :category,
                     allow_blank: false,
                     values: { value: -> { Restriction::CATEGORIES }, message: 'admin.restriction.invalid_category'}
            optional :range,
                     type: String,
                     values: { value: ->(p) { %w[created updated].include?(p) }, message: 'admin.restriction.invalid_range' },
                     default: 'created'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, Restriction

            restrictions = Restriction.all
            restrictions = params[:category] ? restrictions.where(category: params[:category]) : restrictions
            restrictions = params[:scope] ? restrictions.where(scope: params[:scope]) : restrictions
            restrictions = params[:to] ? restrictions.where("#{params[:range]}_at <= ?", Time.at(params[:to].to_i)) : restrictions
            restrictions = params[:from] ? restrictions.where("#{params[:range]}_at >= ?", Time.at(params[:from].to_i)) : restrictions

            present paginate(restrictions), with: API::V2::Entities::Restriction
          end

          desc 'Create whitelink',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'Created whitelink' }
          params do
            optional :expire_time,
                     allow_blank: false,
                     default: 1,
                     values: { value: 1..30, message: 'invalid_expire' },
                     type: Integer,
                     desc: 'link will be active for (Time.now + expire_time in following range)'
            optional :range,
                     allow_blank: false,
                     default: 'day',
                     values: { value: ->(p) { %w[day hour].include?(p) }, message: 'invalid_range' },
                     type: String,
                     desc: 'In combination with expire_time gives full controll over token expiration'
          end
          post '/whitelink' do
            admin_authorize! :create, Restriction

            whitelink_token = Digest::SHA256.hexdigest(SecureRandom.hex(10))

            expires_in = params[:range] == 'day' ? params[:expire_time].days : params[:expire_time].hours
            Rails.cache.write(whitelink_token, 'active', expires_in: expires_in)

            response = { whitelink_token: whitelink_token }
            present response
          end

          desc 'Create restriction',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'Restriction was created' }
          params do
            requires :scope,
                     allow_blank: false,
                     values: { value: -> { Restriction::SCOPES }, message: 'admin.restriction.invalid_scope'}
            requires :value,
                     allow_blank: false
            requires :category,
                     type: String,
                     values: { value: -> { Restriction::CATEGORIES }, message: 'admin.restriction.invalid_category'},
                     allow_blank: false
            optional :state,
                     default: 'enabled',
                     allow_blank: false,
                     values: { value: -> { Restriction::STATES }, message: 'admin.restriction.invalid_state' }
            optional :code,
                     type: Integer,
                     allow_blank: false
          end
          post do
            admin_authorize! :create, Restriction

            restriction = Restriction.new(declared(params, include_missing: false))

            code_error!(restriction.errors.details, 422) unless restriction.save

            # clear cached restrictions, so they will be freshly refetched on the next call to /auth
            Rails.cache.delete('restrictions')
            status 200
          end

          desc 'Update restriction',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'Restriction was updated' }
          params do
            requires :id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Restriction id'
            optional :scope,
                     allow_blank: false,
                     values: { value: -> { Restriction::SCOPES }, message: 'admin.restriction.invalid_scope' }
            optional :category,
                     type: String,
                     values: { value: -> { Restriction::CATEGORIES }, message: 'admin.restriction.invalid_category'},
                     allow_blank: false
            optional :value,
                     allow_blank: false
            optional :state,
                     allow_blank: false,
                     values: { value: -> { Restriction::STATES }, message: 'admin.restriction.invalid_state' }
            optional :code,
                     type: Integer,
                     allow_blank: false
          end
          put do
            admin_authorize! :update, Restriction

            target_restriction = Restriction.find_by(id: params[:id])

            error!({ errors: ['admin.restriction.doesnt_exist'] }, 404) if target_restriction.nil?

            unless target_restriction.update(declared(params, include_missing: false))
              code_error!(target_restriction.errors.details, 422)
            end

            # clear cached restrictions, so they will be freshly refetched on the next call to /auth
            Rails.cache.delete('restrictions')
            status 200
          end

          desc 'Delete restriction',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'Restriction was deleted' }
          params do
            requires :id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Restriction id'
          end
          delete do
            admin_authorize! :destroy, Restriction

            target_restriction = Restriction.find_by(id: params[:id])

            error!({ errors: ['admin.restriction.doesnt_exist'] }, 404) if target_restriction.nil?

            target_restriction.destroy
            # clear cached restrictions, so they will be freshly refetched on the next call to /auth
            Rails.cache.delete('restrictions')

            status 200
          end
        end
      end
    end
  end
end
