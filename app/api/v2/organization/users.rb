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
            requires :oid,
                     type: String,
                     desc: 'organization oid'
          end
          get do
            admin_authorize! :read, ::Organization

            org = ::Organization.find_by_oid(params[:oid])
            error!({ errors: ['organization.organization.doesnt_exist'] }, 404) if org.nil?

            oids = [org.id]
            oids.concat(::Organization.with_parents(org.id).pluck(:id)) if org.parent_organization.nil?
            members = ::Membership.with_organizations(oids)

            present members, with: API::V2::Organization::Entities::Membership
          end
        end

        resource :user do
          helpers ::API::V2::NamedParams

          desc 'Returns organizations of user',
               failure: [],
               success: API::V2::Organization::Entities::UserOrganization
          params do
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'user uid'
            use :pagination_filters
          end
          get '/:uid' do
            admin_authorize! :read, ::Organization

            user = ::User.find_by_uid(params[:uid])
            error!({ errors: ['organization.user.doesnt_exist'] }, 404) if user.nil?

            members = ::Membership.with_users(user.id)
            present paginate(members), with: API::V2::Organization::Entities::UserOrganization
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
            requires :uid,
                     type: String,
                     desc: 'user uid'
            requires :oid,
                     type: String,
                     desc: 'organization oid'
            requires :role,
                     type: String,
                     desc: 'organization user role'
          end
          post do
            admin_authorize! :create, ::Organization

            role = params[:role]
            unless Ability.organization_roles.include? role
              error!({ errors: ['organization.membership.role_not_permitted'] },
                     401)
            end

            user = ::User.find_by_uid(params[:uid])
            org = ::Organization.find_by_oid(params[:oid])
            error!({ errors: ['organization.membership.doesnt_exist'] }, 404) if user.nil? || org.nil?

            member = ::Membership.with_organizations(org.id).with_users(user.id).first
            if member.present?
              # Found duplication; update role
              member.role = role
            else
              member = ::Membership.new({ user_id: user.id, organization_id: org.id, role: role })
            end

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
            admin_authorize! :destroy, ::Organization

            member = ::Membership.find(params[:membership_id])
            error!({ errors: ['organization.membership.doesnt_exist'] }, 404) if member.nil?

            member.destroy
            status 200
          end
        end
      end
    end
  end
end
