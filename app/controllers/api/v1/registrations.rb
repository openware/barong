# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Registrations < Grape::API
      helpers Doorkeeper::Grape::Helpers

      desc 'Registrations related routes'
      resource :registration do
        desc 'Creates new account'
        params do
          requires :email, type: String, desc: 'Account Email'
          requires :password, type: String, desc: 'Account Password'
        end
        post do
          account = Account.create(email: params[:email], password: params[:password])
          error!(account.errors.full_messages, 422) unless account.persisted?
        end
      end
    end
  end
end
