# frozen_string_literal: true

module API
  module V2
    module Resource
      # data storage C functionality
      class DataStorage < Grape::API
        resource :data_storage do
          desc 'Create data storage',
            failure: [
              { code: 401, message: 'Invalid bearer token' },
              { code: 422, message: 'Validation errors' }
            ],
            success: { code: 201, message: 'Data Storage was created' }
          params do
            requires :title,
                     type: String,
                     allow_blank: false,
                     desc: 'Storage title'
            requires :data,
                     type: String,
                     allow_blank: false,
                     desc: 'Storage data'
          end
          post do
            declared_params = declared(params)

            data_storage = current_user.data_storages.new(declared_params)

            code_error!(data_storage.errors.details, 422) unless data_storage.save

            current_user.labels.create(key: data_storage.title, value: 'recorded', scope: 'private')
            status 201
          end
        end
      end
    end
  end
end
