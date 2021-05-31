# frozen_string_literal: true

module API
  module V2
    module Organization
      class Accounts < Grape::API
        resource :accounts do
          helpers ::API::V2::NamedParams
          helpers do
            def permitted_search_params(params)
              params.slice(:keyword)
            end
          end

          desc 'Returns array of accounts which user have access as paginated collection',
               failure: [
                 { code: 404, message: 'Account not found' }
               ],
               success: API::V2::Organization::Entities::SessionAccount
          params do
            use :pagination_filters
          end

          get do
            # Check user has AdminSwitchSession/SwitchSession ability
            is_admin_switch_session = organization_ability? :read, ::AdminSwitchSession
            is_switch_session = organization_ability? :read, ::SwitchSession
            if !is_admin_switch_session && !is_switch_session
              error!({ errors: ['organization.ability.not_permitted'] }, 401)
            end

            # Check account in the organization that user belong to
            members = ::Membership.with_all_organizations
                                .with_users(current_user.id)
                                .select('memberships.*,organizations.name, organizations.parent_organization')
                                .pluck(:organization_id, :'organizations.name', :'organizations.parent_organization')
                                .map { |id, name, pid| { id: id, name: name, pid: pid } }

            # Verify barong admin has AdminSwitchSession ability
            if organization_ability? :read, ::AdminSwitchSession
              # User is barong organization admin
              oids = ::Organization.all.pluck(:id)
            else
              # User is organizationn admin/account
              oids = ::Organization.where(id: members.pluck(:id)).pluck(:id)
              members.select { |m| m[:pid].nil? }.each do |m|
                oids.concat(::Organization.with_parents(m[:id]).pluck(:id))
              end
            end
            error!({ errors: ['identity.member.not_found'] }, 404) if oids.length.zero?

            # Get all accounts for organization admin even if no membership belong to
            accounts = API::V2::Queries::AccountFilter
                       .new(::Organization.with_all_memberships
                                        .where(id: oids))
                       .call(permitted_search_params(params))
                       .distinct

            present paginate(accounts), with: API::V2::Organization::Entities::SessionAccount
          end
        end
      end
    end
  end
end
