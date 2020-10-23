# frozen_string_literal: true

module API::V2
  module Management
    # Labels-related API
    class Labels < Grape::API
      helpers ::API::V2::NamedParams

      helpers do
        def user
          @user ||= User.find_by!(uid: params[:user_uid])
        end

        def permitted_search_params(params)
          params.slice(:key, :value, :from, :to, :range, :scope)
        end
      end

      desc 'Label related routes'
      resource :labels do
        desc 'Get all labels assigned to users' do
          @settings[:scope] = :read_users
          success API::V2::Entities::User
        end
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          optional :value, type: String, allow_blank: false, desc: 'Label value.'
          optional :scope, type: String, allow_blank: false, desc: 'Label scope.'
          optional :extended,
                   type: { value: Boolean, message: 'Non boolean extended value' },
                   default: false,
                   desc: 'When true endpoint returns full information about users'
          optional :range,
                   type: String,
                   values: { value: ->(p) { %w[created updated].include?(p) }, message: 'Invalid range' },
                   default: 'created'

          use :pagination_filters
        end
        post '/filter/users' do
          entity = params[:extended] ? API::V2::Entities::UserWithProfile : API::V2::Entities::User
          users = API::V2::Queries::UserWithLabelFilter.new(User.all).call(permitted_search_params(params))

          present paginate(users), with: entity

          status 200
        end

        desc 'Get user collection filtered on label attributes' do
          @settings[:scope] = :read_labels
          success API::V2::Entities::AdminLabelView
        end
        params do
          requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
        end
        post '/list' do
          present user.labels, with: API::V2::Entities::AdminLabelView
        end

        desc "Create a label with 'private' scope and assigns to users" do
          @settings[:scope] = :write_labels
          success API::V2::Entities::Label
        end
        params do
          requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
          optional :description, type: String, allow_blank: false, desc: 'Label desc.'
        end
        post do
          label = user.labels.create(key: params[:key],
                                     value: params[:value],
                                     description: params[:description],
                                     scope: 'private')
          if label.errors.any?
            error!(label.errors.as_json(full_messages: true), 422)
          end

          present label, with: API::V2::Entities::Label
        end

        desc "Update a label with 'private' scope" do
          @settings[:scope] = :write_labels
          success API::V2::Entities::Label
        end
        params do
          requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
          optional :description, type: String, allow_blank: false, desc: 'Label desc.'
          optional :replace, type: Boolean, default: true, desc: 'When true label will be created if not exist'
        end
        put do
          label = user.labels.find_by(key: params[:key], scope: 'private')

          if label.nil?
            if params[:replace]
              label = Label.create(
                user_id: user.id,
                key: params[:key],
                value: params[:value],
                description: params[:description],
                scope: params[:scope] || 'private'
              )
            else
              error!({ error: 'label doesnt exist' }, 404)
            end
          else
            label.update({ value: params[:value], description: params[:description] }.compact)
          end

          error!(label.errors.as_json(full_messages: true), 422) if label.errors.any?

          present label, with: API::V2::Entities::Label
        end

        desc "Delete a label with 'private' scope" do
          @settings[:scope] = :write_labels
        end
        params do
          requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
        end
        post '/delete' do
          user.labels.find_by!(key: params[:key], scope: 'private').destroy

          status 204
        end
      end
    end
  end
end
