# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over permissions table
      class Permissions < Grape::API
        resource :permissions do
          helpers do
            def validate_params!(params)
              unless %w(get post delete put head).include?(params[:verb].downcase)
                error!({ errors: ['admin.permissions.invalid_verb'] }, 422)
              end

              error!({ errors: ['admin.permissions.invalid_action'] }, 422) unless %w(accept drop audit).include?(params[:action].downcase)
            end
          end

          desc 'Returns array of permissions as paginated collection',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :page,
                     type: { value: Integer, message: 'admin.user.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'admin.user.non_positive_page'},
                     default: 1,
                     desc: 'Page number (defaults to 1).'
            optional :limit,
                     type: { value: Integer, message: 'admin.user.non_integer_limit' },
                     values: { value: 1..100, message: 'admin.user.invalid_limit' },
                     default: 100,
                     desc: 'Number of users per page (defaults to 100, maximum is 100).'
          end
          get do
            Permission.all.tap { |q| present paginate(q) }
          end

          desc 'Create permission',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :role,
                     type: String,
                     allow_blank: false
            requires :verb,
                     type: String,
                     allow_blank: false
            requires :path,
                     type: String,
                     allow_blank: false
            requires :action,
                     type: String,
                     allow_blank: false
          end
          post do
            validate_params!(params)

            declared_params = declared(params, include_missing: false)

            error!({ errors: ['admin.permission.role_doesnt_exist'] }, 422) if Permission.where(role: params[:role]).empty?

            permission = Permission.new(declared_params)

            code_error!(permission.errors.details, 422) unless permission.save

            # clear cached permissions, so they will be freshly refetched on the next call to /auth
            Rails.cache.write('permissions', nil)
            status 200
          end

          desc 'Deletes permission',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'permission id'
          end
          delete do
            target_permission = Permission.find(params[:id])

            error!({ errors: ['admin.permission.doesnt_exist'] }, 404) if target_permission.nil?

            target_permission.destroy
            # clear cached permissions, so they will be freshly refetched on the next call to /auth
            Rails.cache.write('permissions', nil)

            status 200
          end

          desc 'Update Permission',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :id,
                     type: String,
                     allow_blank: false,
                     desc: 'Permission id'
            optional :role,
                     type: String,
                     allow_blank: false,
                     desc: 'permission field - role'
            optional :req_type,
                     type: Boolean,
                     allow_blank: false,
                     desc: 'permission field - request type'
            optional :path,
                     type: String,
                     allow_blank: false,
                     desc: 'permission field - request path'
            optional :action,
                     type: String,
                     allow_blank: false
            exactly_one_of :action, :role, :req_type, :path, message: 'admin.permission.one_of_role_type_path_action'
          end
          put do
            target_permission = Permission.find(params[:id])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:id).keys.first
            update_param_value = params.except(:id).values.first

            error!({ errors: ['admin.permission.doesnt_exist'] }, 404) if target_permission.nil?

            if update_param_value == target_permission[update_param_key]
              error!({ errors: ["admin.permission.#{update_param_key}_no_change"] }, 422)
            end

            unless target_permission.update(update_param_key => update_param_value)
              code_error!(target_permission.errors.details, 422)
            end
            # clear cached permissions, so they will be freshly refetched on the next call to /auth
            Rails.cache.write('permissions', nil)

            status 200
          end
        end
      end
    end
  end
end
