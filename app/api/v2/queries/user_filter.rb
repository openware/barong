# queries helping module
module API::V2::Queries
  class UserFilter
    attr_accessor :initial_scope

    # initialize query to get User.all
    def initialize(initial_scope)
      @initial_scope = initial_scope.left_outer_joins(:profile)
    end

    # returns query with with all applied filters
    def call(params)
      scoped = filter_by_date(initial_scope, params[:range], params[:from], params[:to])
      scoped = filter_by_uid(scoped, params[:uid])
      scoped = filter_by_email(scoped, params[:email])
      scoped = filter_by_role(scoped, params[:role])
      scoped = filter_by_first_name(scoped, params[:first_name])
      scoped = filter_by_last_name(scoped, params[:last_name])
      scoped = filter_by_country(scoped, params[:country])
      scoped = filter_by_level(scoped, params[:level])
      scoped = filter_by_state(scoped, params[:state])
      scoped
    end

    private

    # adds where(users.[created, updated]_at > from and users.[created, updated]_at < to) to query
    def filter_by_date(scoped, range = 'created', from = nil, to = nil)
      updated_scope = from ? scoped.where("users.#{range}_at >= ?", Time.at(from.to_i)) : scoped
      to ? updated_scope.where("users.#{range}_at <= ?", Time.at(to.to_i)) : updated_scope
    end

    # adds where(users.uid = uid) to query
    def filter_by_uid(scoped, uid = nil)
      uid ? scoped.where(users: { uid: uid }) : scoped
    end

    # adds where(users.email = email) to query
    def filter_by_email(scoped, email = nil)
      email ? scoped.where(users: { email: email }) : scoped
    end

    # adds where(users.role = role) to query
    def filter_by_role(scoped, role = nil)
      role ? scoped.where(users: { role: role }) : scoped
    end

    # adds where(users.level = level) to query
    def filter_by_level(scoped, level = nil)
      level ? scoped.where(users: { level: level }) : scoped
    end

    # adds where(users.state = state) to query
    def filter_by_state(scoped, state = nil)
      state ? scoped.where(users: { state: state }) : scoped
    end

    # adds where(users.first_name = first_name) to query
    def filter_by_first_name(scoped, first_name = nil)
      first_name ? scoped.where(profiles: { first_name: first_name }) : scoped
    end

    # adds where(users.last_name = last_name) to query
    def filter_by_last_name(scoped, last_name = nil)
      last_name ? scoped.where(profiles: { last_name: last_name }) : scoped
    end

    # adds where(users.country = country) to query
    def filter_by_country(scoped, country = nil)
      country ? scoped.where(profiles: { country: country }) : scoped
    end
  end
end
