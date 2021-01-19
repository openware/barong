# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over profiles table
      class Profiles < Grape::API
        resource :profiles do
          helpers ::API::V2::NamedParams

          desc 'Return all profiles',
             failure: [
               { code: 401, message: 'Invalid bearer token' },
             ],
             success: API::V2::Admin::Entities::Profile
          params do
            use :pagination_filters
          end

          get do
            admin_authorize! :read, Profile

            present paginate(Profile.all), with: API::V2::Admin::Entities::Profile
          end

          desc "Verify user's profile",
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 422, message: 'Validation errors' }
            ],
            success: API::V2::Admin::Entities::Profile
          params do
            requires :uid, type: String
            requires :state, type: String
          end

          put do
            admin_authorize! :update, Profile

            target_profile = User.find_by(uid: params[:uid])&.submitted_profile
            return error!({ errors: ['admin.profiles.doesnt_exist_or_not_editable'] }, 404) if target_profile.nil?

            if target_profile.user.superadmin? && !current_user.superadmin?
              error!({ errors: ['admin.profiles.superadmin_change'] }, 422)
            end

            if Barong::App.config.profile_double_verification && target_profile.author \
               && target_profile.author == current_user.uid && !BarongConfig.list['profile_verification_roles']&.include?(current_user.role)
              error!({ errors: ['admin.profiles.second_admin_approval'] }, 422)
            end

            unless target_profile.update(declared(params.except(:uid), include_missing: false))
              code_error!(target_profile.errors.details, 422)
            end

            present target_profile, with: API::V2::Admin::Entities::Profile
          end

          desc 'Create a profile for user',
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 422, message: 'Validation errors' }
            ],
            success: API::V2::Admin::Entities::Profile
          params do
            requires :uid, type: String
            optional :first_name, type: String
            optional :last_name, type: String
            optional :dob, type: Date
            optional :address, type: String
            optional :postcode, type: String
            optional :city, type: String
            optional :country, type: String
            optional :metadata, type: String, desc: 'Any additional key: value pairs in json string format'
          end

          post do
            target_user = User.find_by(uid: params[:uid])

            declared_params = declared(params.except(:uid), include_missing: false)
            declared_params.merge!(state: 'submitted', author: current_user.uid)

            profile = target_user.profiles.create(declared_params)
            code_error!(profile.errors.details, 422) if profile.errors.any?

            present profile, with: API::V2::Admin::Entities::Profile
            status 201
          end
        end
      end
    end
  end
end
