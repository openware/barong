# frozen_string_literal: true

# queries helping module
module API::V2::Queries
  class AccountFilter
    attr_accessor :initial_scope

    # initialize query
    def initialize(initial_scope)
      @initial_scope = initial_scope
    end

    # returns query with with all applied filters
    def call(params)
      (filter_by_name(@initial_scope, params[:keyword])).or(filter_by_uid(@initial_scope, params[:keyword]))
    end

    private

    # adds where(organization.name starts with name) to query
    def filter_by_name(scoped, name = nil)
      name ? scoped.where("name LIKE '#{name}%'") : scoped
    end

    # adds where(user.uid starts with uid) to query
    def filter_by_uid(scoped, uid = nil)
      uid ? scoped.where("memberships.user_id IN (SELECT id FROM users WHERE uid LIKE '#{uid}%')") : scoped
    end
  end
end
