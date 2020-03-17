# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over profiles table
      class Profiles < Grape::API
        resource :profiles do
          helpers ::API::V2::NamedParams

          desc 'Return all profiles',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
             ]
          params do
            use :pagination_filters
          end

          get do
            present paginate(Profile.all), with: API::V2::Entities::Profile
          end

          desc 'Update a profile for user',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ]
          params do
            requires :uid, type: String
            optional :first_name, type: String
            optional :last_name, type: String
            optional :dob, type: Date
            optional :address, type: String
            optional :postcode, type: String
            optional :city, type: String
            optional :country, type: String
            optional :state, type: String
            optional :metadata, type: String, desc: 'Any additional key: value pairs in json string format'
          end

          put do
            target_profile = User.find_by(uid: params[:uid])&.submitted_profile
            return error!({ errors: ['admin.profiles.doesnt_exist_or_not_editable'] }, 404) if target_profile.nil?

            if target_profile.user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.profiles.superadmin_change'] }, 422)
            end

            unless target_profile.update(declared(params.except(:uid), include_missing: false))
              code_error!(target_profile.errors.details, 422)
            end

            present target_profile, with: API::V2::Entities::Profile
          end
        end
      end
    end
  end
end
