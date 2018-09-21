# frozen_string_literal: true

module UserApi
  module V1
    # Responsible for CRUD for labes
    class Labels < Grape::API
      resource :labels do
        desc 'List all labels for current account.',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' }
             ]
        get do
          present current_account.labels, with: Entities::Label
        end

        desc 'Return a label by key.',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
        end
        route_param :key do
          get do
            label = current_account.labels.find_by!(key: params[:key])
            present label, with: Entities::Label
          end
        end

        desc "Create a label with 'public' scope.",
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
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
            present label, with: Entities::Label
          else
            error!(label.errors.as_json(full_messages: true), 422)
          end
        end

        desc "Update a label with 'public' scope.",
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
          requires :value, type: String, allow_blank: false, desc: 'Label value.'
        end
        patch ':key' do
          label = current_account.labels.find_by!(key: params[:key])
          return error!('Can\'t update Label.', 400) if label.private?

          label.update(value: params[:value])
          present label, with: Entities::Label
        end

        desc "Delete a label  with 'public' scope.",
             security: [{ "BearerToken": [] }],
             success: { code: 204, message: 'Succefully deleted' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :key, type: String, allow_blank: false, desc: 'Label key.'
        end
        delete ':key' do
          label = current_account.labels.find_by!(key: params[:key])
          return error!('Can\'t update Label.', 400) if label.private?

          label.destroy
          status 204
        end
      end
    end
  end
end
