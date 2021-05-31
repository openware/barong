# frozen_string_literal: true

module API
  module V2
    module Organization
      class Account < Grape::API
        resource :account do
          helpers ::API::V2::NamedParams

          desc 'Return organization accounts',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 401, message: 'Organization ability not permitted' },
                 { code: 404, message: 'Record does not exists' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Organization::Entities::OrganizationAccount
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
            else
              organization_authorize!

              # oid will be ignored if user is organization admin
              # Org will be user's default organization
              org = current_organization
            end

            if org.nil? || !org.parent_organization.nil?
              # Don't need to get accounts for account of organization
              error!({ errors: ['organization.organization.doesnt_exist'] },
                     404)
            end

            present ::Organization.with_parents(org.id),
                    with: API::V2::Organization::Entities::OrganizationAccount
          end

          desc 'Create account in organization',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 401, message: 'Organization ability not permitted' },
                 { code: 404, message: 'Record does not exists' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Organization::Entities::OrganizationAccount
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
            unless organization_ability? :create, ::Organization
              organization_authorize!

              # You need to be belong to the parent organization
              if !id.nil? && id != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] },
                       401)
              end

              id = current_organization.id
            end
            # Validate the organization need to be parent organization
            parent = ::Organization.find(id)
            if parent.nil? || !parent.parent_organization.nil?
              error!({ errors: ['organization.organization.doesnt_exist'] },
                     404)
            end

            # You cannot add organization with the same name into parent organization
            organizations = ::Organization.with_parents(id).where(name: params[:name])
            if !organizations.nil? && organizations.length.positive?
              error!({ errors: ['organization.organization.already_exist'] }, 401)
            end

            org = ::Organization.new({
                                     parent_organization: id,
                                     name: params[:name],
                                     status: params[:status]
                                   })
            code_error!(org.errors.details, 422) unless org.save

            present org, with: API::V2::Organization::Entities::OrganizationAccount
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
            organization = ::Organization.where.not(parent_organization: nil).find(params[:organization_id])
            error!({ errors: ['organization.membership.doesnt_exist'] }, 404) if organization.nil?

            unless organization_ability? :destroy, ::Organization
              organization_authorize!

              if organization.parent_organization != current_organization.id
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
