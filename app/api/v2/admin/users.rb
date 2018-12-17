# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over users table
      class Users < Grape::API
        resource :users do
          desc 'Returns array of users as paginated collection',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
            optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
          end
          get do
            User.all.page(params[:page]).per(params[:limit]).collect do |user|
              user.attributes.except('password_digest')
            end
          end

          desc 'Changes user state',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid, type: String, desc: 'user uniq id', allow_blank: false
            requires :state, type: String, desc: 'user uniq id', allow_blank: false
          end
          post do
            target_user = User.find_by_uid(params[:uid])
            error!('User with such UID doesnt exist', 404) if target_user.nil?

            error!('State already setted to this', 403) if target_user.state == params[:state]

            target_user.update(state: params[:state])
            status 200
          end

          desc 'Returns user info',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :uid, type: String, desc: 'user uniq id', allow_blank: false
          end
          get '/:uid' do
            target_user = User.find_by_uid(params[:uid])
            error!('User with such UID doesnt exist', 404) if target_user.nil?

            present target_user, with: API::V2::Entities::UserWithFullInfo
          end

          namespace :labels do
            desc 'Adds label for user',
            security: [{ "BearerToken": [] }],
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
            params do
              requires :uid, type: String, desc: 'user uniq id', allow_blank: false
              requires :key, type: String, desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.', allow_blank: false
              requires :value, type: String, desc: 'label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.', allow_blank: false
              optional :scope, type: String, desc: "Label scope: 'public' or 'private'. Default is public", allow_blank: false
            end
            post do
              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!('User with such UID doesnt exist', 404) if target_user.nil?
              declared_params[:user_id] = target_user.id

              label = Label.new(declared_params.except(:uid))

              error!(label.errors.full_messages, 422) unless label.save

              status 200
            end

            desc 'Deletes label for user',
            security: [{ "BearerToken": [] }],
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
            params do
              requires :uid, type: String, desc: 'user uniq id', allow_blank: false
              requires :key, type: String, desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.', allow_blank: false
              requires :scope, type: String, desc: 'label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.', allow_blank: false
            end
            delete do
              declared_params = declared(params, include_missing: false)

              target_user = User.find_by_uid(params[:uid])
              error!('User with such UID doesnt exist', 404) if target_user.nil?

              label = Label.find_by_key_and_user_id_and_scope(declared_params[:key], target_user.id, declared_params[:scope])

              error!('Label with such key doesnt exist or not assigned to chosen user', 404) if label.nil?

              label.delete
              status 200
            end
          end
        end
      end
    end
  end
end
