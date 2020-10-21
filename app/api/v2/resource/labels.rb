# frozen_string_literal: true

module API
  module V2
    module Resource
      # Responsible for CRUD for labes
      class Labels < Grape::API
        resource :labels do
          desc 'List all labels for current user.',
               security: [{ "BearerToken": [] }],
               failure: [
                 { code: 401, message: 'Invalid bearer token' }
               ]
          get do
            present current_user.labels, with: Entities::Label
          end

          desc 'Return a label by key.',
               security: [{ "BearerToken": [] }],
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
          route_param :key do
            get do
              label = current_user.labels.find_by!(key: params[:key])
              present label, with: Entities::Label
            end
          end
        end
      end
    end
  end
end
