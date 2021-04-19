# frozen_string_literal: true

module API
  module V2
    module Commercial
      # Admin functionality over abilities
      class Organizations < Grape::API
        resource :organizations do
          helpers ::API::V2::NamedParams

          desc 'Returns array of organizations',
               failure: [],
               success: API::V2::Commercial::Entities::Organization
          params do
            use :pagination_filters
          end
          get do
            admin_organization_authorize!

            organizations = Organization.where(organization_id: nil)
            present paginate(organizations), with: API::V2::Commercial::Entities::Organization
          end

          desc 'Create organization',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Commercial::Entities::Organization
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
            admin_organization_authorize!

            declared_params = declared(params, include_missing: false)
            org_params = declared_params.slice('name', 'group')

            organization = Organization.new(org_params)
            code_error!(organization.errors.details, 422) unless organization.save

            present organization, with: API::V2::Commercial::Entities::Organization
          end
        end

        resource :organization do
          helpers ::API::V2::NamedParams

          desc 'Return organizations details',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Commercial::Entities::Organization
          params do
            optional :oid,
                     type: String,
                     allow_blank: false,
                     desc: 'organization oid'
          end
          get do
            if admin_organization?
              # User is barong admin organization, oid is required
              error!({ errors: ['required.params.missing'] }, 400) if params[:oid].nil?

              org = Organization.find_by_oid(params[:oid])
              error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if org.nil?
            else
              organization_authorize!

              org = if params[:oid].nil?
                      # User is organization admin/account so, org will be user's default organization
                      current_organization
                    else
                      Organization.find_by_oid(params[:oid])
                    end
              error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if org.nil?

              # Check the oid need to be organization/subunit which user belong to
              if org.organization_id.nil?
                error!({ errors: ['organization.ability.not_permitted'] }, 401) if org.id != current_organization.id
              elsif org.organization_id != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            present org,
                    with: API::V2::Commercial::Entities::OrganizationWithFullInfo
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
          post '/update' do
            organization = Organization.find(params[:organization_id])
            error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if organization.nil?

            unless admin_organization?
              organization_authorize!

              # Organization admin cannot change organization details
              error!({ errors: ['organization.ability.not_permitted'] }, 401) if organization.organization_id.nil?

              # You need to be in the organization
              if organization.organization_id != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:organization_id).keys.first
            update_param_value = params.except(:organization_id).values.first

            error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if organization.nil?

            if update_param_value == organization[update_param_key]
              error!({ errors: ["commercial.organization.#{update_param_key}_no_change"] }, 422)
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
          post '/setting' do
            organization = Organization.find(params[:organization_id])
            error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if organization.nil?

            unless admin_organization?
              organization_authorize!

              # Organization admin cannot change organization setting
              error!({ errors: ['organization.ability.not_permitted'] }, 401) if organization.organization_id.nil?

              # You need to be in the organization
              if organization.organization_id != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            # Ruby Hash returns array on keys and values
            update_param_key = params.except(:organization_id).keys.first
            update_param_value = params.except(:organization_id).values.first

            error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if organization.nil?

            if update_param_value == organization[update_param_key]
              error!({ errors: ["commercial.organization.#{update_param_key}_no_change"] }, 422)
            end

            unless organization.update(update_param_key => update_param_value)
              code_error!(organization.errors.details, 422)
            end

            status 200
          end

          namespace :users do
            desc 'Return organization users',
                 failure: [
                   { code: 400, message: 'Required params are missing' },
                   { code: 401, message: 'Organization ability not permitted' },
                   { code: 404, message: 'Record does not exists' },
                   { code: 422, message: 'Validation errors' }
                 ],
                 success: API::V2::Commercial::Entities::Membership
            params do
              optional :oid,
                       type: String,
                       allow_blank: false,
                       desc: 'organization oid'
            end
            get do
              if admin_organization?
                # User is barong admin organization, oid is required
                error!({ errors: ['required.params.missing'] }, 400) if params[:oid].nil?

                org = Organization.find_by_oid(params[:oid])
                error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if org.nil?
              else
                organization_authorize!

                org = if params[:oid].nil?
                        # User is organization admin/account so, org will be user's default organization
                        current_organization
                      else
                        Organization.find_by_oid(params[:oid])
                      end
                error!({ errors: ['commercial.organization.doesnt_exist'] }, 404) if org.nil?

                # Check the oid need to be organization/subunit which user belong to
                if org.organization_id.nil?
                  error!({ errors: ['organization.ability.not_permitted'] }, 401) if org.id != current_organization.id
                elsif org.organization_id != current_organization.id
                  error!({ errors: ['organization.ability.not_permitted'] }, 401)
                end
              end

              oids = [org.id]
              oids.concat(Organization.where(organization_id: org.id).pluck(:id)) if org.organization_id.nil?
              members = Membership.where(organization_id: oids)

              present members, with: API::V2::Commercial::Entities::Membership
            end

            desc 'Add user into organization',
                 failure: [
                   { code: 400, message: 'Required params are missing' },
                   { code: 401, message: 'Organization ability not permitted' },
                   { code: 404, message: 'Record does not exists' },
                   { code: 422, message: 'Validation errors' }
                 ],
                 success: { code: 200, message: 'User of organization was deleted' }
            params do
              requires :user_id,
                       type: Integer,
                       desc: 'user id'
              requires :organization_id,
                       type: Integer,
                       desc: 'organization id'
            end
            post do
              # You cannot add user as barong organization admin
              error!({ errors: ['organization.ability.not_permitted'] }, 401) if params[:organization_id].zero?
              members = Membership.where(user_id: params[:user_id], organization_id: params[:organization_id])
              if !members.nil? && members.length.positive?
                error!({ errors: ['commercial.membership.already_exist'] }, 401)
              end

              unless admin_organization?
                organization_authorize!

                org = Organization.find(params[:organization_id])
                if org.organization_id.nil?
                  # You cannot add user as organization admin, only admin organization can do this!
                  error!({ errors: ['organization.ability.not_permitted'] }, 401)
                elsif org.organization_id != current_organization.id
                  # To add membership user need to be admin of that organization
                  error!({ errors: ['organization.ability.not_permitted'] }, 401)
                end
              end

              declared_params = declared(params, include_missing: false)
              member_params = declared_params.slice('user_id', 'organization_id')

              member = Membership.new(member_params)
              code_error!(member.errors.details, 422) unless member.save

              present member, with: API::V2::Commercial::Entities::Membership
            end

            desc 'Delete user in organization',
                 failure: [
                   { code: 400, message: 'Required params are missing' },
                   { code: 401, message: 'Organization ability not permitted' },
                   { code: 404, message: 'Record does not exists' },
                   { code: 422, message: 'Validation errors' }
                 ],
                 success: { code: 200, message: 'User of organization was deleted' }
            params do
              requires :membership_id,
                       type: Integer,
                       desc: 'membership id'
            end
            delete do
              # You cannot remove barong admin organizations
              member = Membership.where.not(organization_id: 0).find(params[:membership_id])
              error!({ errors: ['commercial.membership.doesnt_exist'] }, 404) if member.nil?

              unless admin_organization?
                organization_authorize!

                org = member.organization
                if org.organization_id.nil?
                  # You cannot remove organization admin, only admin organization can do this!
                  error!({ errors: ['organization.ability.not_permitted'] }, 401)
                elsif org.organization_id != current_organization.id
                  # To delete membership user need to be admin of that organization
                  error!({ errors: ['organization.ability.not_permitted'] }, 401)
                end
              end
              member.destroy
              status 200
            end
          end

          namespace :accounts do
            desc 'Return organization accounts',
                 failure: [
                   { code: 400, message: 'Required params are missing' },
                   { code: 401, message: 'Organization ability not permitted' },
                   { code: 404, message: 'Record does not exists' },
                   { code: 422, message: 'Validation errors' }
                 ],
                 success: API::V2::Commercial::Entities::OrganizationAccount
            params do
              optional :oid,
                       type: String,
                       allow_blank: false,
                       desc: 'organization oid'
            end
            get do
              if admin_organization?
                # User is barong admin organization, oid is required
                error!({ errors: ['required.params.missing'] }, 400) if params[:oid].nil?

                org = Organization.find_by_oid(params[:oid])
              else
                organization_authorize!

                # oid will be ignored if user is organization admin
                # Org will be user's default organization
                org = current_organization
              end

              if org.nil? || !org.organization_id.nil?
                # Don't need to get accounts for account of organization
                error!({ errors: ['commercial.organization.doesnt_exist'] },
                       404)
              end

              present Organization.where(organization_id: org.id),
                      with: API::V2::Commercial::Entities::OrganizationAccount
            end

            desc 'Create account in organization',
                 failure: [
                   { code: 400, message: 'Required params are missing' },
                   { code: 401, message: 'Organization ability not permitted' },
                   { code: 404, message: 'Record does not exists' },
                   { code: 422, message: 'Validation errors' }
                 ],
                 success: API::V2::Commercial::Entities::OrganizationAccount
            params do
              optional :organization_id,
                       type: Integer,
                       desc: 'parent organization id'
              requires :name,
                       type: String,
                       allow_blank: false,
                       desc: 'account name'
              requires :status,
                       type: String,
                       allow_blank: false,
                       desc: 'account status'
            end
            post do
              id = params[:organization_id]
              unless admin_organization?
                organization_authorize!

                # You need to be belong to the parent organization
                error!({ errors: ['organization.ability.not_permitted'] }, 401) if id != current_organization.id

                id = current_organization.id
              end
              # Validate the organization need to be parent organization
              parent = Organization.where(organization_id: nil, id: id)
              error!({ errors: ['organization.ability.not_permitted'] }, 401) if parent.nil? || parent.length.zero?

              # You cannot add organization with the same name into parent organization
              organizations = Organization.where(name: params[:name], organization_id: id)
              if !organizations.nil? && organizations.length.positive?
                error!({ errors: ['commercial.organization.already_exist'] }, 401)
              end

              org = Organization.new({
                                       organization_id: id,
                                       name: params[:name],
                                       status: params[:status]
                                     })
              code_error!(org.errors.details, 422) unless org.save

              present org, with: API::V2::Commercial::Entities::OrganizationAccount
            end

            desc 'Delete account in organization',
                 failure: [
                   { code: 400, message: 'Required params are missing' },
                   { code: 401, message: 'Organization ability not permitted' },
                   { code: 404, message: 'Record does not exists' },
                   { code: 422, message: 'Validation errors' }
                 ],
                 success: { code: 200, message: 'Account of organization was deleted' }
            params do
              requires :organization_id,
                       type: Integer,
                       desc: 'organization account id'
            end
            delete do
              # You cannot remove parent organizations
              organization = Organization.where.not(organization_id: nil).find(params[:organization_id])
              error!({ errors: ['commercial.membership.doesnt_exist'] }, 404) if organization.nil?

              unless admin_organization?
                organization_authorize!

                if organization.organization_id != current_organization.id
                  # To delete organization account you need to be admin of that organization
                  error!({ errors: ['organization.ability.not_permitted'] }, 401)
                end
              end
              organization.destroy
              status 200
            end
          end
        end
      end
    end
  end
end
