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
            # Check user has AdminSwitchSession/SubunitSwitchSession ability
            is_admin_switch_session = organization_ability? :read, ::AdminSwitchSession
            is_organization_switch_session = organization_ability? :read, ::OrganizationSwitchSession
            is_switch_session = organization_ability? :read, ::SubunitSwitchSession
            if !is_admin_switch_session && !is_switch_session && !is_organization_switch_session
              error!({ errors: ['organization.ability.unpermitted'] }, 401)
            end

            user = ::User.find_by!(uid: current_user.origin_uid)
            # Verify barong admin has AdminSwitchSession ability
            if is_admin_switch_session
              # User has AdminSwitchSession ability
              oids = ::Organization.all.pluck(:id)

              # Get search keyword
              keyword = params[:keyword]
              # Take current user as results
              users_collection = ::User.where(role: ::OrganizationPlugin::ADMIN_SWITCH_SESSION_AUTHORIZED_ROLES)
                                       .or(::User.where(uid: user.uid))
              if keyword.nil?
                users = users_collection.to_a
              else
                # Take matched uid or email
                users = users_collection.where('uid LIKE ? OR email LIKE ?', "%#{keyword}%", "%#{keyword}%").to_a
                # Take matched user profile name
                filtered = users_collection.select do |m|
                  m.verified_profile.full_name.downcase.include?(keyword.downcase) if m.verified_profile.present?
                end
                users.concat(filtered)
              end
            else
              # User has OrganizationSwitchSession/SubunitSwitchSession ability
              # Check account in the organization that user belong to
              members = ::Membership.with_all_organizations
                                    .with_users(user.id)
                                    .select('memberships.*,organizations.name, organizations.parent_organization')
                                    .pluck(:organization_id, :'organizations.name', :'organizations.parent_organization')
                                    .map { |id, name, pid| { id: id, name: name, pid: pid } }

              oids = ::Organization.where(id: members.pluck(:id)).pluck(:id)
              members.select { |m| m[:pid].nil? }.each do |m|
                oids.concat(::Organization.with_parents(m[:id]).pluck(:id))
              end
            end
            error!({ errors: ['identity.organization.empty'] }, 404) if oids.length.zero?

            # Get all accounts for organization admin even if no membership belong to
            orgs = API::V2::Queries::AccountFilter
                   .new(::Organization.with_all_memberships
                                      .with_actives
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

            if users.present?
              # Get user uid in organizations
              uids = (::Organization.with_all_memberships.with_actives.map(&:memberships).flatten.map { |m| m.user.uid }).uniq
              # Get only user which NOT belong to organization
              individual_users = users.select { |u| u.state == 'active' }.reject { |u| uids.include? u.uid }.uniq(&:id)
              accounts.concat(individual_users.map do |m|
                                name = m.verified_profile.present? ? m.verified_profile.full_name : m.email
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
