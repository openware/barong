module API::V2::Queries
  class ActivityFilter
    attr_accessor :initial_scope

    # initialize query to get Activity.all.joins(:user)
    def initialize(initial_scope)
      @initial_scope = initial_scope.joins(:user)
    end

    # returns query with with all applied filters
    def call(params)
      scoped = filter_by_date(initial_scope, params[:created_from], params[:created_to])
      scoped = filter_by_topic(scoped, params[:topic])
      scoped = filter_by_action(scoped, params[:action])
      scoped = filter_by_uid(scoped, params[:uid])
      scoped = filter_by_email(scoped, params[:email])
      scoped.order('activities.created_at DESC')
    end

    # adds where(activities.created_at > from and activities.created_at < to) to query
    private
    def filter_by_date(scoped, from = nil, to = nil)
      updated_scope = from ? scoped.where('activities.created_at >= ?', from) : scoped
      to ? updated_scope.where('activities.created_at <= ?', to) : updated_scope
    end

    # adds where(activities.topic = topic) to query
    def filter_by_topic(scoped, topic = nil)
      topic ? scoped.where(activities: {topic: topic}) : scoped
    end

    # adds where(activities.action = action) to query
    def filter_by_action(scoped, action = nil)
      action ? scoped.where(activities: {action: action}) : scoped
    end

    # adds where(users.uid = uid) to query
    def filter_by_uid(scoped, uid = nil)
      uid ? scoped.where(users: {uid: uid}) : scoped
    end

    # adds where(users.email = email) to query
    def filter_by_email(scoped, email = nil)
      email ? scoped.where(users: {email: email}) : scoped
    end
  end
end
