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
            admin_organization_authorize! :read, ::Organization

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
            admin_organization_authorize! :create, ::Organization

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
            optional :oid,
                     type: String,
                     allow_blank: false,
                     desc: 'organization oid'
          end
          get do
            if organization_ability? :read, ::Organization
              # User is barong admin organization, oid is required
              error!({ errors: ['required.params.missing'] }, 400) if params[:oid].nil?

              org = ::Organization.find_by_oid(params[:oid])
              error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if org.nil?
            else
              organization_authorize!

              org = if params[:oid].nil?
                      # User is organization admin/account so, org will be user's default organization
                      current_organization
                    else
                      ::Organization.find_by_oid(params[:oid])
                    end
              error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if org.nil?

              # Check the oid need to be organization/subunit which user belong to
              if org.parent_organization.nil?
                error!({ errors: ['organization.ability.not_permitted'] }, 401) if org.id != current_organization.id
              elsif org.parent_organization != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

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
            organization = ::Organization.find(params[:organization_id])
            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if organization.nil?

            unless organization_ability? :update, ::Organization
              organization_authorize!

              # Organization admin cannot change organization details
              error!({ errors: ['organization.ability.not_permitted'] }, 401) if organization.parent_organization.nil?

              # You need to be in the organization
              if organization.parent_organization != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:organization_id).keys.first
            update_param_value = params.except(:organization_id).values.first

            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if organization.nil?

            if update_param_value == organization[update_param_key]
              error!({ errors: ["organization.organization.#{update_param_key}_no_change"] }, 422)
            end

            unless organization.update(update_param_key => update_param_value)
              code_error!(organization.errors.details, 422)
            end

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
            organization = ::Organization.find(params[:organization_id])
            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if organization.nil?

            unless organization_ability? :update, ::Organization
              organization_authorize!

              # Organization admin cannot change organization setting
              error!({ errors: ['organization.ability.not_permitted'] }, 401) if organization.parent_organization.nil?

              # You need to be in the organization
              if organization.parent_organization != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:organization_id).keys.first
            update_param_value = params.except(:organization_id).values.first

            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if organization.nil?

            if update_param_value == organization[update_param_key]
              error!({ errors: ["organization.organization.#{update_param_key}_no_change"] }, 422)
            end

            unless organization.update(update_param_key => update_param_value)
              code_error!(organization.errors.details, 422)
            end

            status 200
          end
        end
      end
    end
  end
end
