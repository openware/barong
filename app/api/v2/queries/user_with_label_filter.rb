# queries helping module
module API::V2::Queries
  class UserWithLabelFilter
    attr_accessor :initial_scope

    # initialize query to get User.all
    def initialize(initial_scope)
      @initial_scope = initial_scope.left_outer_joins(:labels)
    end

    # returns query with with all applied filters
    def call(params)
      scoped = filter_by_date(initial_scope, params[:range], params[:from], params[:to])
      scoped = filter_by_key(scoped, params[:key])
      scoped = filter_by_value(scoped, params[:value])
      scoped = filter_by_scope(scoped, params[:scope])

      scoped
    end

    private

    # adds where(labels.[created, updated]_at > from and labels.[created, updated]_at < to) to query
    def filter_by_date(scoped, range = 'created', from = nil, to = nil)
      newer_than_sql = "labels.#{range}_at >= ?"
      older_than_sql = "labels.#{range}_at <= ?"

      updated_scope = from ? scoped.where(newer_than_sql, Time.at(from.to_i)) : scoped
      to ? updated_scope.where(older_than_sql, Time.at(to.to_i)) : updated_scope
    end

    # adds where(labels.key = key) to query
    def filter_by_key(scoped, key = nil)
      key ? scoped.where(labels: { key: key }) : scoped
    end

    # adds where(labels.value = value) to query
    def filter_by_value(scoped, value = nil)
      value ? scoped.where(labels: { value: value }) : scoped
    end

    # adds where(labels.scope = scope) to query
    def filter_by_scope(scoped, scope = nil)
      scope ? scoped.where(labels: { scope: scope }) : scoped
    end
  end
end
