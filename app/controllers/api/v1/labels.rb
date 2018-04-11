# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    # Responsible for CRUD for labes
    class Labels < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before { doorkeeper_authorize! }

      before do
        def current_account
          Account.find(doorkeeper_token.resource_owner_id)
        end
      end

      resource :labels do
        desc 'List all labels for current account.'
        get do
          present current_account.labels, with: API::Entities::Label
        end

        desc 'Return a label by key.'
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
        end
        route_param :key do
          get do
            label = current_account.labels.find_by(key: params[:key])
            return error!('Couldn\'t find Label', 404) if label.blank?

            present label, with: API::Entities::Label
          end
        end

        desc "Create a label with 'public' scope."
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
        end
        post do
          label =
            current_account.labels.new(
              key: params[:key],
              value: params[:value],
              scope: 'public'
            )
          if label.save
            present label, with: API::Entities::Label
          else
            error!(label.errors.as_json(full_messages: true), 422)
          end
        end

        desc "Update a label with 'public' scope."
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
        end
        patch ':key' do
          label = current_account.labels.find_by(key: params[:key])
          return error!('Couldn\'t find Label', 404) if label.blank?
          return error!('Can\'t update Label.', 400) if label.private?

          label.update(value: params[:value])
          present label, with: API::Entities::Label
        end

        desc "Delete a label  with 'public' scope."
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
        end
        delete ':key' do
          label = current_account.labels.find_by(key: params[:key])
          return error!('Couldn\'t find Label', 404) if label.blank?
          return error!('Can\'t update Label.', 400) if label.private?

          label.destroy
          status 204
        end
      end
    end
  end
end
