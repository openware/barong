# frozen_string_literal: true

module API::V2
  module Resource
    class Profiles < Grape::API
      desc 'Profile related routes'
      resource :profiles do
        desc 'Return profile of current resource owner',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'User has no profile' }
             ]
        get '/me' do
          error!('User has no profile', 404) unless current_user.profile
          current_user.profile.as_json(only: %i[first_name last_name dob address country city postcode state metadata])
        end

        desc 'Create a profile for current_user',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 409, message: 'Profile already exists' },
               { code: 422, message: 'Validation errors' }
             ]
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
          return error!('Profile already exists', 409) unless current_user.profile.nil?
          profile = current_user.create_profile(declared(params, include_missing: false))
          error!(profile.errors.full_messages.to_sentence, 422) if profile.errors.any?
          
          label =
              current_user.labels.new(
                key: 'profile',
                value: 'verified',
                scope: 'private'
              )
            error!(label.errors.as_json(full_messages: true), 422) unless label.save

          status 201
        end
      end
    end
  end
end
