# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over users table
      class Users < Grape::API
        resource :users do
          helpers ::API::V2::NamedParams
          helpers do
            def permitted_search_params(params)
              params.slice(:uid, :email, :role, :first_name, :last_name, :country, :level, :state, :from, :to, :range)
            end

            def search(field, value)
              error!({ errors: ['admin.user.non_user_field'] }, 422) unless User.attribute_names.include?(field)

              User.where("#{field}": value).order('email ASC')
            end
          end

          desc 'Returns array of users as paginated collection',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Entities::User
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
            optional :country,
                     type: String
            optional :level,
                     type: Integer
            optional :state,
                     type: String
            optional :range,
                     type: String,
                     values: { value: -> (p){ %w[created updated].include?(p) }, message: 'admin.user.invalid_range' },
                     default: 'created'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'user.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     values: { value: -> (p){ User.new.attributes.keys.include?(p) }, message: 'user.ordering.invalid_attribute' },
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :timeperiod_filters
            use :pagination_filters
          end
          get do
            admin_authorize! :read, User

            entity = params[:extended] ? API::V2::Admin::Entities::UserWithProfile : API::V2::Entities::User
            users = API::V2::Queries::UserFilter.new(User.all.order(params[:order_by] => params[:ordering])).call(params).uniq
            present paginate(users), with: entity
          end

          desc 'Update user attributes',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'User attributes were updated' }
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
            admin_authorize! :update, User

            target_user = User.find_by_uid(params[:uid])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:uid).keys.first
            update_param_value = params.except(:uid).values.first

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            if target_user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.user.superadmin_change'] }, 422)
            end

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

            target_user.labels.find_by(key: :otp, scope: :private).delete if target_user.labels.find_by(key: :otp, scope: :private) && update_param_key == 'otp'
            status 200
          end

          desc 'Update user role',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'User role was created' }
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
            admin_authorize! :update, User

            target_user = User.find_by_uid(params[:uid])

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            if target_user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.user.superadmin_change'] }, 422)
            end

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
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'User attributes were created' }
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            optional :email,
                     type: String,
                     allow_blank: false,
                     desc: 'User Email'
            optional :state,
                     type: String,
                     allow_blank: false,
                     desc: 'user state'
            optional :otp,
                     type: Boolean,
                     allow_blank: false,
                     desc: 'user 2fa status'
            exactly_one_of :state, :otp, :email, message: 'admin.user.one_of_state_otp_email'
          end
          put do
            admin_authorize! :update, User

            target_user = User.find_by_uid(params[:uid])

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:uid).keys.first
            update_param_value = params.except(:uid).values.first

            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            if target_user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.user.superadmin_change'] }, 422)
            end

            error!({ errors: ['admin.user.update_himself'] }, 422) if target_user.uid == current_user.uid

            if update_param_key == 'email' && !current_user.superadmin?
              error!({ errors: ['superadmin.user.update_email'] }, 422)
            end

            if update_param_key == 'otp' && update_param_value == true
              error!({ errors: ['admin.user.enable_2fa'] }, 422)
            end

            if update_param_value == target_user[update_param_key]
              error!({ errors: ["admin.user.#{update_param_key}_no_change"] }, 422)
            end

            unless target_user.update(update_param_key => update_param_value)
              code_error!(target_user.errors.details, 422)
            end

            target_user.labels.find_by(key: :otp, scope: :private).delete if target_user.labels.find_by(key: :otp, scope: :private) && update_param_key == 'otp'
            status 200
          end

          desc 'Returns array of users with pending or replaced documents as paginated collection',
               failure: [
                   { code: 401, message: 'Invalid bearer token' }
               ],
               success: API::V2::Entities::User
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
                     values: { value: ->(p) { %w[created updated].include?(p) }, message: 'admin.user.invalid_range' },
                     default: 'created'
            use :timeperiod_filters
            use :pagination_filters
          end
          get '/documents/pending' do
            admin_authorize! :read, User

            users_with_pending_or_replaced_docs = User.with_pending_or_replaced_docs.order('labels.updated_at ASC')

            users = API::V2::Queries::UserFilter.new(users_with_pending_or_replaced_docs).call(params)

            entity = params[:extended] ? API::V2::Admin::Entities::UserWithKYC : API::V2::Entities::User
            present paginate(users), with: entity
          end

          namespace :labels do
            desc 'Returns existing labels keys and values',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ]
            params do
            end
            get '/list' do
              admin_authorize! :read, User

              labels = Label.where(scope: 'private').group(:key, :value).size

              present labels
            end

            desc 'Returns array of users as paginated collection',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: API::V2::Entities::User
            params do
              requires :key,      type: String, desc: 'Label key'
              requires :value,    type: String, desc: 'Label value'
              use :pagination_filters
            end
            get do
              admin_authorize! :read, User

              users = User.joins(:labels).where(labels: { key: params[:key], value: params[:value] })

              present paginate(users), with: API::V2::Entities::User
            end

            desc 'Add label for user',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: { code: 200, message: 'Label was created' }
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
              optional :description,
                       type: String,
                       allow_blank: false,
                       desc: 'label description. [A-Za-z0-9_-] should be used. max - 255 characters.'
              optional :scope, type: String, desc: "Label scope: 'public' or 'private'. Default is public", allow_blank: false
            end
            post do
              admin_authorize! :create, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              declared_params[:user_id] = target_user.id

              label = Label.new(declared_params.except(:uid))

              code_error!(label.errors.details, 422) unless label.save

              status 200
            end

            desc 'Update user label value',
              failure: [
                { code: 400, message: 'Required params are empty' },
                { code: 401, message: 'Invalid bearer token' },
                { code: 404, message: 'Record is not found' },
                { code: 422, message: 'Validation errors' }
              ],
              success: { code: 200, message: 'Label was updated' }
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
              optional :description,
                       type: String,
                       allow_blank: false,
                       desc: 'label description. [A-Za-z0-9_-] should be used. max - 255 characters.'
              optional :replace,
                       type: { value: Boolean, message: 'admin.user.non_boolean_replace' },
                       default: true,
                       desc: 'When true label will be created if not exist'
            end
            post '/update' do
              admin_authorize! :update, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(declared_params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              if label.nil?
                if declared_params[:replace]
                  label = Label.create(
                    user_id: target_user.id,
                    key: declared_params[:key],
                    value: declared_params[:value],
                    scope: declared_params[:scope],
                    description: declared_params[:description]
                  )
                else
                  error!({ errors: ['admin.label.doesnt_exist'] }, 404)
                end
              else
                label.update({ value: params[:value], description: params[:description] })
              end
              code_error!(label.errors.details, 422) if label.errors.any?

              status 200
            end

            desc 'Update user label scope',
              failure: [
                { code: 400, message: 'Required params are empty' },
                { code: 401, message: 'Invalid bearer token' },
                { code: 404, message: 'Record is not found' },
                { code: 422, message: 'Validation errors' }
              ],
              success: { code: 200, message: 'Label was updated' }
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
              optional :description,
                       type: String,
                       allow_blank: false,
                       desc: 'label description. [A-Za-z0-9_-] should be used. max - 255 characters.'
              requires :value,
                       type: String,
                       allow_blank: false,
                       desc: 'Label value.'
            end
            put do
              admin_authorize! :update, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(declared_params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              unless label.update({ value: params[:value], description: params[:description] }.compact)
                code_error!(label.errors.details, 422)
              end
              status 200
            end

            desc 'Deletes label for user',
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: { code: 200, message: 'Label was deleted' }
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
              admin_authorize! :destroy, Label

              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              if target_user.superadmin? && !current_user.superadmin?
                error!({ errors: ['admin.user.superadmin_change'] }, 422)
              end

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!({ errors: ['admin.label.doesnt_exist'] }, 404) if label.nil?

              label.destroy
              status 200
            end
          end

          desc 'Returns user info',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Admin::Entities::UserWithKYC
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
          end
          get '/:uid' do
            admin_authorize! :read, User

            target_user = User.find_by_uid(params[:uid])
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            present target_user, with: API::V2::Admin::Entities::UserWithKYC
          end

          desc "Deletes user's data storage record",
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Admin::Entities::UserWithKYC
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uniq id'
            requires :title,
                     type: String,
                     allow_blank: false,
                     desc: 'data storage uniq title'
          end
          delete '/data_storage' do
            admin_authorize! :destroy, User

            target_user = User.find_by_uid(params[:uid])
            error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

            storage = target_user.data_storages.find_by_title(params[:title])
            error!({ errors: ['admin.storage.doesnt_exist'] }, 404) if storage.nil?

            target_user.labels.find_by(key: storage.title, scope: 'private')
            storage.destroy
            present target_user, with: API::V2::Admin::Entities::UserWithKYC
          end

          namespace :comments do
            desc "Adds new user's comment",
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: API::V2::Admin::Entities::UserWithKYC
            params do
              requires :uid,
                       type: String,
                       allow_blank: false,
                       desc: 'user uniq id'
              requires :title,
                       type: String,
                       values: { value: -> (v){ v.length <= 64 }, message: 'admin.comments.title_too_long'},
                       allow_blank: false,
                       desc: 'comment uniq title'
              requires :data,
                       type: String,
                       values: { value: -> (v){ v.length <= 65535 }, message: 'admin.comments.data_too_long'},
                       allow_blank: false,
                       desc: 'comment data'
            end
            post do
              target_user = User.find_by_uid(params[:uid])
              error!({ errors: ['admin.user.doesnt_exist'] }, 404) if target_user.nil?

              comment = Comment.new(
                                      user_id: target_user.id,
                                      data: params[:data],
                                      title: params[:title],
                                      author_uid: current_user[:uid],
                                    )

              code_error!(data_storage.errors.details, 422) unless comment.save

              present target_user, with: API::V2::Admin::Entities::UserWithKYC
            end

            desc "Edit user's comment",
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: API::V2::Admin::Entities::UserWithKYC
            params do
              requires :id,
                       type: Integer,
                       desc: 'comment uniq id'
              optional :title,
                       type: String,
                       values: { value: -> (v){ v.length <= 64 }, message: 'admin.comments.title_too_long'},
                       allow_blank: false,
                       desc: 'comment title'
              optional :data,
                       type: String,
                       values: { value: -> (v){ v.length <= 65535 }, message: 'admin.comments.data_too_long'},
                       allow_blank: false,
                       desc: 'comment data'
            end
            put do
              comment = Comment.find(params[:id])
              error!({ errors: ['admin.comment.doesnt_exist'] }, 404) if comment.nil?

              code_error!(comment.errors.details, 422) unless comment.update(params.slice(:data, :title))

              present comment.user, with: API::V2::Admin::Entities::UserWithKYC
            end

            desc "Delete user's comment",
              failure: [
                { code: 401, message: 'Invalid bearer token' }
              ],
              success: API::V2::Admin::Entities::UserWithKYC
            params do
              requires :id,
                       type: Integer,
                       desc: 'comment uniq id'
            end
            delete do
              comment = Comment.find(params[:id])
              error!({ errors: ['admin.comment.doesnt_exist'] }, 404) if comment.nil?

              code_error!(comment.errors.details, 422) unless comment.destroy

              present comment.user, with: API::V2::Admin::Entities::UserWithKYC
            end
          end
        end
      end
    end
  end
end
