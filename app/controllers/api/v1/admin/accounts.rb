# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    module Admin
      class Accounts < Grape::API
        desc 'Accounts related routes'
        resource :accounts do
          desc 'Return information about current resource owner'
          get '/' do
            authorize! :read, Account
            Account.all.as_json(only: %i[uid email level role state])
          end

          desc 'Update role of account'
          post '/set_role' do
            authorize! :write, Account
            Account.find_by_uid(params[:uid]).update(role: params[:role])
          end
        end
      end
    end
  end
end
