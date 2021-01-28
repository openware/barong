# frozen_string_literal: true

module API
  module V2
    module Resource
      # Responsible for CRUD for labes
      class Labels < Grape::API
        resource :labels do
          desc 'List all labels for current user.',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: Entities::Label
          params do
            optional :ordering,
                     type: String,
                     values: { value: %w(asc desc) },
                     default: 'asc',
                     desc: 'If set, returned labels sorted in specific order, default to "asc".'
          end
          get do
            labels = current_user.labels.order(created_at: params[:ordering])
            present labels, with: Entities::Label
          end

          desc 'Return a label by key.',
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 404, message: 'Record is not found' }
            ],
            success: Entities::Label
          params do
            requires :key,
                     type: String,
                     allow_blank: false,
                     desc: 'Label key.'
          end
          route_param :key do
            get do
              label = current_user.labels.find_by!(key: params[:key])
              present label, with: Entities::Label
            end
          end

          desc "Create a label with 'public' scope.",
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 422, message: 'Validation errors' }
            ],
            success: Entities::Label
          params do
            requires :key,
                     type: String,
                     allow_blank: false,
                     desc: 'Label key.'
            requires :value,
                     type: String,
                     allow_blank: false,
                     desc: 'Label value.'
          end
          post do
            label =
              current_user.labels.new(
                key: params[:key],
                value: params[:value],
                scope: 'public'
              )
            if label.save
              present label, with: Entities::Label
            else
              code_error!(label.errors.details, 422)
            end
          end

          desc "Update a label with 'public' scope.",
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 404, message: 'Record is not found' },
              { code: 422, message: 'Validation errors' }
            ],
            success: Entities::Label
          params do
            requires :key,
                     type: String,
                     allow_blank: false,
                     desc: 'Label key.'
            requires :value,
                     type: String,
                     allow_blank: false,
                     desc: 'Label value.'
          end
          patch ':key' do
            label = current_user.labels.find_by!(key: params[:key])
            return error!({ errors: ['resource.labels.private'] }, 400) if label.private?

            label.update(value: params[:value])
            present label, with: Entities::Label
          end

          desc "Delete a label  with 'public' scope.",
            success: { code: 204, message: 'Succefully deleted' },
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 404, message: 'Record is not found' }
            ]
          params do
            requires :key,
                     type: String,
                     allow_blank: false,
                     desc: 'Label key.'
          end
          delete ':key' do
            label = current_user.labels.find_by!(key: params[:key])
            return error!({ errors: ['resource.labels.private'] }, 400) if label.private?

            label.destroy
            status 204
          end
        end
      end
    end
  end
end
