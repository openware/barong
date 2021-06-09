# frozen_string_literal: true

module API
  module V2
    module Organization
      class Organizations < Grape::API
        resource do
          helpers ::API::V2::NamedParams

          desc 'Returns array of organizations',
               failure: [],
               success: API::V2::Organization::Entities::Organization
          params do
            use :pagination_filters
          end
          get '/all' do
            admin_authorize! :read, ::Organization

            organizations = ::Organization.with_parents
            present paginate(organizations), with: API::V2::Organization::Entities::Organization
          end

          desc 'Create organization',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Organization::Entities::Organization
          params do
            requires :name,
                     type: String,
                     allow_blank: false,
                     desc: 'organization name'
            requires :group,
                     type: String,
                     allow_blank: false,
                     desc: 'organization fee group'
          end
          post do
            admin_authorize! :create, ::Organization

            declared_params = declared(params, include_missing: false)
            organization = ::Organization.new(declared_params)
            code_error!(organization.errors.details, 422) unless organization.save

            present organization, with: API::V2::Organization::Entities::Organization
          end

          desc 'Return organizations details',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Organization::Entities::Organization
          params do
            requires :oid,
                     type: String,
                     desc: 'organization oid'
          end
          get do
            admin_authorize! :read, ::Organization

            org = ::Organization.find_by_oid(params[:oid])
            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if org.nil?

            present org,
                    with: API::V2::Organization::Entities::OrganizationWithFullInfo
          end

          desc 'Update organization',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: { code: 200, message: 'Organization attributes was updated' }
          params do
            requires :organization_id,
                     type: Integer,
                     desc: 'organization id'
            optional :name,
                     type: String,
                     allow_blank: false,
                     desc: 'organization name'
            optional :country,
                     type: String,
                     desc: 'organization country'
            optional :city,
                     type: String,
                     desc: 'organization city'
            optional :phone,
                     type: String,
                     desc: 'organization contact number'
            optional :email,
                     type: String,
                     desc: 'organization contact email'
            optional :address,
                     type: String,
                     desc: 'organization address'
            optional :postcode,
                     type: String,
                     desc: 'organization postcode'
          end
          put '/update' do
            admin_authorize! :update, ::Organization

            organization = ::Organization.find(params[:organization_id])
            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if organization.nil?

            code_error!(organization.errors.details, 422) unless organization.update(params.except(:organization_id))

            status 200
          end

          desc 'Update organization setting',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: { code: 200, message: 'Organization setting was updated' }
          params do
            requires :organization_id,
                     type: Integer,
                     desc: 'organization id'
            optional :status,
                     type: String,
                     allow_blank: false,
                     desc: 'organization status'
            optional :group,
                     type: String,
                     desc: 'organization group'
          end
          put '/settings' do
            admin_authorize! :update, ::Organization

            organization = ::Organization.find(params[:organization_id])
            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if organization.nil?

            code_error!(organization.errors.details, 422) unless organization.update(params.except(:organization_id))

            status 200
          end

          desc 'Returns abilities in organization'
          get '/abilities' do
            Ability.organization_permissions[current_user.role] || {}
          end

          desc 'Returns roles of organization'
          get '/roles' do
            Ability.organization_roles || []
          end
        end
      end
    end
  end
end
