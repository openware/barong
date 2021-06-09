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
            if is_admin_switch_session
              # User has AdminSwitchSession ability
              oids = ::Organization.all.pluck(:id)

              # Take users
              users = if params[:keyword].nil?
                        ::User.all
                      else
                        ::User.where("uid LIKE '#{params[:keyword]}%'")
                      end
            else
              # User has SwitchSession ability
              oids = ::Organization.where(id: members.pluck(:id)).pluck(:id)
              members.select { |m| m[:pid].nil? }.each do |m|
                oids.concat(::Organization.with_parents(m[:id]).pluck(:id))
              end
            end
            error!({ errors: ['identity.member.not_found'] }, 404) if oids.length.zero?

            # Get all accounts for organization admin even if no membership belong to
            orgs = API::V2::Queries::AccountFilter
                   .new(::Organization.with_all_memberships
                                          .where(id: oids))
                   .call(permitted_search_params(params))
                   .distinct
            accounts = orgs.map do |m|
              {
                name: m.name,
                oid: m.oid,
                uid: nil
              }
            end

            unless users.nil?
              # Get user uid in organizations
              uids = (orgs.map(&:memberships).flatten.map { |m| m.user.uid }).uniq
              # Get only user which NOT belong to organization
              individual_users = users.reject { |u| uids.include? u.uid }
              accounts.concat(individual_users.map do |m|
                                name = ''
                                if m.profiles.length.positive?
                                  profile = m.profiles[0]
                                  name = "#{profile.first_name} #{profile.last_name}"
                                end
                                {
                                  name: name,
                                  oid: nil,
                                  uid: m.uid
                                }
                              end)
            end

            present paginate(accounts), with: API::V2::Organization::Entities::SessionAccount
          end
        end
      end
    end
  end
end
