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
        end
        post do
          generated_password = Devise.friendly_token.first(8)
          account = Account.create(email: params[:email], password: generated_password)
          return error!(account.errors.full_messages, 422) unless account.persisted?

          'Account is created'
        end
      end
    end
  end
end
