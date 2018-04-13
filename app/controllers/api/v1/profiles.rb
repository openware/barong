# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Profiles < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account
          Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end

      desc 'Profile related routes'
      resource :profiles do
        desc 'Return profile of current resource owner'
        get do
          current_account.profile.as_json(only: %i[first_name last_name dob address country city postcode state metadata])
        end

        desc 'Create a profile for current_account'
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :dob, type: Date
          requires :address, type: String
          requires :postcode, type: String
          requires :city, type: String
          requires :country, type: String
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        post do
          return error!('Profile already exists', 409) unless current_account.profile.nil?
          current_account.profile = Profile.new(declared(params, include_missing: false))
          error!(current_account.errors.full_messages.to_sentence, 422) unless current_account.save
        end
      end
    end
  end
end
