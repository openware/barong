# frozen_string_literal: true

module API
  module V2
    module Organization
      class Users < Grape::API
        resource :users do
          helpers ::API::V2::NamedParams

          desc 'Return organization users',
               failure: [
                 { code: 400, message: 'Required params are missing' },
                 { code: 401, message: 'Organization ability not permitted' },
                 { code: 404, message: 'Record does not exists' },
                 { code: 422, message: 'Validation errors' }
               ],
               success: API::V2::Organization::Entities::Membership
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
                if org.id != current_organization.id
                  error!({ errors: ['organization.ability.not_permitted'] },
                         401)
                end
              elsif org.parent_organization != current_organization.id
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            oids = [org.id]
            oids.concat(::Organization.with_parents(org.id).pluck(:id)) if org.parent_organization.nil?
            members = ::Membership.with_organizations(oids)

            present members, with: API::V2::Organization::Entities::Membership
          end
        end

        resource :user do
          helpers ::API::V2::NamedParams

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
            members = ::Membership.with_users(params[:user_id]).with_organizations(params[:organization_id])
            if !members.nil? && members.length.positive?
              error!({ errors: ['organization.membership.already_exist'] }, 401)
            end

            unless organization_ability? :create, ::Organization
              organization_authorize!

              org = ::Organization.find(params[:organization_id])
              if org.parent_organization.nil?
                # You cannot add user as organization admin, only admin organization can do this!
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              elsif org.parent_organization != current_organization.id
                # To add membership user need to be admin of that organization
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end

            declared_params = declared(params, include_missing: false)
            member_params = declared_params.slice('user_id', 'organization_id')

            member = ::Membership.new(member_params)
            code_error!(member.errors.details, 422) unless member.save

            present member, with: API::V2::Organization::Entities::Membership
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
            member = ::Membership.find(params[:membership_id])
            error!({ errors: ['organization.membership.doesnt_exist'] }, 404) if member.nil?

            unless organization_ability? :destroy, ::Organization
              organization_authorize!

              org = member.organization
              if org.parent_organization.nil?
                # You cannot remove organization admin, only admin organization can do this!
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              elsif org.parent_organization != current_organization.id
                # To delete membership user need to be admin of that organization
                error!({ errors: ['organization.ability.not_permitted'] }, 401)
              end
            end
            member.destroy
            status 200
          end
        end
      end
    end
  end
end
