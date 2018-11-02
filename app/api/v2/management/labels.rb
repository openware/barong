# frozen_string_literal: true

module API::V2
    module Management
      class Labels < Grape::API
        helpers do
          def user
            @user ||= User.find_by!(uid: params[:user_uid])
          end
        end

        LabelEntity = API::V2::Entities::Label
  
        desc 'Label related routes'
        resource :labels do
          desc 'Get all labels assigned to users' do
            @settings[:scope] = :read_labels
            success API::V2::Entities::Label
          end
          params do
            requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
          end
          post '/list' do
            present user.labels, with: API::V2::Entities::Label
          end
  
          desc "Create a label with 'private' scope and assigns to users" do
            @settings[:scope] = :write_labels
            success API::V2::Entities::Label
          end
          params do
            requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
            requires :key, type: String, allow_blank: false, desc: 'Label key.'
            requires :value, type: String, allow_blank: false, desc: 'Label value.'
          end
          post do
            label = user.labels.create(key: params[:key],
                                          value: params[:value],
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
          end
          put do
            label = user.labels.find_by!(key: params[:key], scope: 'private')
            label.update(value: params[:value])
  
            if label.errors.any?
              error!(label.errors.as_json(full_messages: true), 422)
            end
  
            present label, with: API::V2::Entities::Label
          end
  
          desc "Delete a label with 'private' scope" do
            @settings[:scope] = :write_labels
            success API::V2::Entities::Label
          end
          params do
            requires :user_uid, type: String, allow_blank: false, desc: 'User uid'
            requires :key, type: String, allow_blank: false, desc: 'Label key.'
          end
          post '/delete' do
            label = user.labels.find_by!(key: params[:key], scope: 'private')
            label.destroy
            status 204
          end
        end
      end
    end
  end
