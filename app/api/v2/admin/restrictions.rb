# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over restrictions table
      class Restrictions < Grape::API
        resource :restrictions do
          desc 'Returns array of restrictions as a paginated collection',
          security: [{ 'BearerToken': [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :scope,
                     allow_blank: false,
                     values: { value: -> { Restriction::SCOPES }, message: 'admin.restriction.invalid_scope'}
            optional :range,
                     type: String,
                     values: { value: ->(p) { %w[created updated].include?(p) }, message: 'admin.restriction.invalid_range' },
                     default: 'created'
            optional :from
            optional :to
            optional :page,
                     type: { value: Integer, message: 'admin.restriction.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'admin.restriction.non_positive_page'},
                     default: 1,
                     desc: 'Page number (defaults to 1).'
            optional :limit,
                     type: { value: Integer, message: 'admin.restriction.non_integer_limit' },
                     values: { value: 1..1000, message: 'admin.restriction.invalid_limit' },
                     default: 100,
                     desc: 'Number of restrictions per page (defaults to 100, maximum is 1000).'
          end
          get do
            restrictions = Restriction.all
            restrictions = params[:scope] ? restrictions.where(scope: params[:scope]) : restrictions
            restrictions = params[:to] ? restrictions.where("#{params[:range]}_at <= ?", Time.at(params[:to].to_i)) : restrictions
            restrictions = params[:from] ? restrictions.where("#{params[:range]}_at >= ?", Time.at(params[:from].to_i)) : restrictions

            present paginate(restrictions)
          end

          desc 'Create restriction',
          security: [{ 'BearerToken': [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :scope,
                     allow_blank: false,
                     values: { value: -> { Restriction::SCOPES }, message: 'admin.restriction.invalid_scope'}
            requires :value,
                     allow_blank: false
            optional :state,
                     default: 'enabled',
                     allow_blank: false,
                     values: { value: -> { Restriction::STATES }, message: 'admin.restriction.invalid_state' }
          end
          post do
            restriction = Restriction.new(declared(params))

            code_error!(restriction.errors.details, 422) unless restriction.save

            # clear cached restrictions, so they will be freshly refetched on the next call to /auth
            Rails.cache.delete('restrictions')
            status 200
          end

          desc 'Update restriction',
          security: [{ 'BearerToken': [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Restriction id'
            optional :scope,
                     allow_blank: false,
                     values: { value: -> { Restriction::SCOPES }, message: 'admin.restriction.invalid_scope' }
            optional :value,
                     allow_blank: false
            optional :state,
                     allow_blank: false,
                     values: { value: -> { Restriction::STATES }, message: 'admin.restriction.invalid_state' }
          end
          put do
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
          security: [{ 'BearerToken': [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Restriction id'
          end
          delete do
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
