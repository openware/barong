# frozen_string_literal: true

module API::V2
  module Resource
    class Sessions < Grape::API
      desc 'Existing session related'
      resource :sessions do
        desc 'Destroy current user session',
        failure: [
          { code: 400, message: 'Required params are empty' },
          { code: 404, message: 'Record is not found' }
        ]
        delete do
          activity_record(user: current_user.id, action: 'logout', result: 'succeed', topic: 'session')

          request.session.destroy
          status(200)
        end
      end
    end
  end
end
