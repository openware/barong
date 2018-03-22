# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    module Admin
      class Applications < Grape::API
        desc 'Application related routes'
        resource :applications do
          desc 'Return documents of specific Account'
          get '/' do
            Doorkeeper::Application.all.as_json
          end

          post '/new' do
            Doorkeeper::Application.create(name: params[:name], redirect_uri: params[:redirect_uri], scopes: params[:scores], skipauth: params[:skipauth])
          end
        end
      end
    end
  end
end
