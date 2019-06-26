# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over users table
      class Users < Grape::API
        helpers do
          def permitted_search_params(params)
            params.slice(:uid, :email, :role, :first_name, :last_name, :country, :level, :state, :from, :to, :range)
          end

          def search(field, value)
            error!({ errors: ['admin.user.non_user_field'] }, 422) unless User.attribute_names.include?(field)

            User.where("#{field}": value).order('email ASC')
          end
        end

        resource :users do
          desc 'Returns array of users as paginated collection',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :extended,
                     type: { value: Boolean, message: 'admin.user.non_boolean_extended' },
                     default: false,
                     desc: 'When true endpoint returns full information about users'
            optional :uid,
                     type: String
            optional :email,
                     type: String
            optional :role,
                     type: String
            optional :first_name,
                     type: String
            optional :last_name,
                     type: String
            optional :country,
                     type: String
            optional :level,
                     type: Integer
            optional :state,
                     type: String
            optional :range,
                     type: String,
                     values: { value: -> (p){ %w[created updated].include?(p) }, message: 'admin.user.non_positive_page' },
                     default: 'created'
            optional :from
            optional :to
            optional :page,
                     type: { value: Integer, message: 'admin.user.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'admin.user.non_positive_page' },
                     default: 1,
                     desc: 'Page number (defaults to 1).'
            optional :limit,
                     type: { value: Integer, message: 'admin.user.non_integer_limit' },
                     values: { value: 1..100, message: 'admin.user.invalid_limit' },
                     default: 100,
                     desc: 'Number of users per page (defaults to 100, maximum is 100).'
          end
          get do
            entity = params[:extended] ? API::V2::Entities::UserWithProfile : API::V2::Entities::User
            users = API::V2::Queries::UserFilter.new(User.all).call(params)
            users.tap { |q| present paginate(q), with: entity }
          end

          desc 'Update user attributes',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            optional :state,
                     type: String,
                     allow_blank: false,
                     desc: 'user state'
            optional :otp,
                     type: Boolean,
                     allow_blank: false,
                     desc: 'user 2fa status'
            exactly_one_of :state, :otp, message: 'admin.user.one_of_state_otp'
          end
          post '/update' do
            target_user = User.find_by_uid(params[:uid])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:uid).keys.first
            update_param_value = params.except(:uid).values.first

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if update_param_key == 'otp' && update_param_value == true
              error!({ errors: ['admin.user.enable_2fa'] }, 422)
            end

            if update_param_value == target_user[update_param_key]
              error!({ errors: ["admin.user.#{update_param_key}_no_change"] }, 422)
            end

            unless target_user.update(update_param_key => update_param_value)
              code_error!(target_user.errors.details, 422)
            end
            status 200
          end

          desc 'Update user role',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            requires :role,
                     type: String,
                     allow_blank: false,
                     desc: 'user role'
          end
          post '/role' do
            target_user = User.find_by_uid(params[:uid])

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if params[:role] == target_user.role
              error!({ errors: ["admin.user.role_no_change"] }, 422)
            end

            unless target_user.update(role: params[:role])
              code_error!(target_user.errors.details, 422)
            end

            status 200
          end

          desc 'Update user attributes',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            optional :state,
                     type: String,
                     allow_blank: false,
                     desc: 'user state'
            optional :otp,
                     type: Boolean,
                     allow_blank: false,
                     desc: 'user 2fa status'
            exactly_one_of :state, :otp, message: 'admin.user.one_of_state_otp'
          end
          put do
            target_user = User.find_by_uid(params[:uid])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:uid).keys.first
            update_param_value = params.except(:uid).values.first

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if update_param_key == 'otp' && update_param_value == true
              error!({ errors: ['admin.user.enable_2fa'] }, 422)
            end

            if update_param_value == target_user[update_param_key]
              error!({ errors: ["admin.user.#{update_param_key}_no_change"] }, 422)
            end

            unless target_user.update(update_param_key => update_param_value)
              code_error!(target_user.errors.details, 422)
            end

            status 200
          end

          desc 'Returns array of users with pending documents as paginated collection',
               security: [{ "BearerToken": [] }],
               failure: [
                   { code: 401, message: 'Invalid bearer token' }
               ]
          params do
            optional :extended,
                     type: { value: Boolean, message: 'admin.user.non_boolean_extended' },
                     default: false,
                     desc: 'When true endpoint returns full information about users'
            optional :uid,
                     type: String
            optional :email,
                     type: String
            optional :role,
                     type: String
            optional :first_name,
                     type: String
            optional :last_name,
                     type: String
            optional :country,
                     type: String
            optional :level,
                     type: Integer
            optional :state,
                     type: String
            optional :range,
                     type: String,
                     values: { value: ->(p) { %w[created updated].include?(p) }, message: 'admin.user.non_positive_page' },
                     default: 'created'
            optional :from
            optional :to
            optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
            optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of users per page (defaults to 100, maximum is 1000).'
          end
          get '/documents/pending' do
            users_with_pending_docs = User.joins(:labels).where(labels: { key: 'document', value: 'pending', scope: 'private' }).order('labels.updated_at ASC')

            users = API::V2::Queries::UserFilter.new(users_with_pending_docs).call(params)

            entity = params[:extended] ? API::V2::Entities::UserWithFullInfo : API::V2::Entities::User
            users.all.tap { |q| present paginate(q), with: entity }
          end

          namespace :labels do
            desc 'Returns existing labels keys and values',
            security: [{ "BearerToken": [] }],
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
            params do
            end
            get '/list' do
              labels = Label.where(scope: 'private').group(:key, :value).size

              present labels

              status 200
            end

            desc 'Returns array of users as paginated collection',
            security: [{ "BearerToken": [] }],
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
            params do
              requires :key,      type: String, desc: 'Label key'
              requires :value,    type: String, desc: 'Label value'
              optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
              optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of users per page (defaults to 100, maximum is 1000).'
            end
            get do
              users = User.joins(:labels).where(labels: { key: params[:key], value: params[:value] })

              users.all.tap { |q| present paginate(q), with: API::V2::Entities::User }
            end

            desc 'Adds label for user',
            security: [{ "BearerToken": [] }],
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.'
              optional :scope, type: String, desc: "Label scope: 'public' or 'private'. Default is public", allow_blank: false
            end
            post do
              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?
              declared_params[:user_id] = target_user.id

              label = Label.new(declared_params.except(:uid))

              code_error!(label.errors.details, 422) unless label.save

              status 200
            end

            desc 'Update user label scope',
            security: [{ 'BearerToken': [] }],
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 404, message: 'Record is not found' },
              { code: 422, message: 'Validation errors' }
            ]
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'Label key.'
              requires :scope,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'Label value.'
            end
            post '/update' do
              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(declared_params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              unless label.update(value: params[:value])
                code_error!(label.errors.details, 422)
              end
              status 200
            end

            desc 'Update user label scope',
                 security: [{ 'BearerToken': [] }],
                 failure: [
                   { code: 400, message: 'Required params are empty' },
                   { code: 401, message: 'Invalid bearer token' },
                   { code: 404, message: 'Record is not found' },
                   { code: 422, message: 'Validation errors' }
                 ]
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'Label key.'
              requires :scope,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'Label value.'
            end
            put do
              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(declared_params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              unless label.update(value: params[:value])
                code_error!(label.errors.details, 422)
              end
              status 200
            end

            desc 'Deletes label for user',
                 security: [{ "BearerToken": [] }],
                 failure: [
                   { code: 401, message: 'Invalid bearer token' }
                 ]
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :key,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
              requires :scope,
                       type: String,
                       allow_blank: false,
                       desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.'
            end
            delete do
              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              label.destroy
              status 200
            end
          end

          desc 'Returns user info',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
          end
          get '/:uid' do
            target_user = User.find_by_uid(params[:uid])
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            present target_user, with: API::V2::Entities::UserWithFullInfo
          end
        end
      end
    end
  end
end
