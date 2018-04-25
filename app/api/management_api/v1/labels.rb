# frozen_string_literal: true

module ManagementAPI
  module V1
    class Labels < Grape::API
      desc 'Label related routes'
      resource :labels do
        desc "Create a label with 'private' scope and assigns to account" do
          @settings[:scope] = :write_labels
          success Entities::Label
        end
        params do
          requires :account_uid, type: String, allow_blank: false, desc: 'Account uid'
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
        end
        post do
          account = Account.find_by!(uid: params[:account_uid])
          label = account.labels.create(key: params[:key],
                                        value: params[:value],
                                        scope: 'private')
          if label.errors.any?
            error!(label.errors.as_json(full_messages: true), 422)
          end

          present label, with: Entities::Label
        end

        desc "Update a label with 'private' scope" do
          @settings[:scope] = :write_labels
          success Entities::Label
        end
        params do
          requires :account_uid, type: String, allow_blank: false, desc: 'Account uid'
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
        end
        put do
          account = Account.find_by!(uid: params[:account_uid])
          label = account.labels.find_by!(key: params[:key], scope: 'private')
          label.update(value: params[:value])

          if label.errors.any?
            error!(label.errors.as_json(full_messages: true), 422)
          end

          present label, with: Entities::Label
        end

        desc "Delete a label with 'private' scope" do
          @settings[:scope] = :write_labels
          success Entities::Label
        end
        params do
          requires :account_uid, type: String, allow_blank: false, desc: 'Account uid'
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
        end
        post '/delete' do
          account = Account.find_by!(uid: params[:account_uid])
          label = account.labels.find_by!(key: params[:key], scope: 'private')
          label.destroy
          status 204
        end
      end
    end
  end
end
