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
      filter_by_oid(@initial_scope, params[:keyword])
        .or(filter_by_name(@initial_scope, params[:keyword]))
    end

    private

    def filter_by_oid(scoped, oid = nil)
      oid ? scoped.where("oid LIKE '%#{oid}%'") : scoped
    end

    def filter_by_name(scoped, name = nil)
      name ? scoped.where("name LIKE '%#{name}%'") : scoped
    end
  end
end
