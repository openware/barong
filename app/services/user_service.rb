# frozen_string_literal: true

class UserService
  def initialize(default_options = {})
    @default_options = default_options
  end

  def activity_record(options = {})
    options = @default_options.merge(options)
    params = {
      category:        'user',
      user_id:         options[:user],
      user_ip:         options[:user_ip],
      user_ip_country: Barong::GeoIP.info(ip: options[:user_ip], key: :country),
      user_agent:      options[:user_agent],
      topic:           options[:topic],
      action:          options[:action],
      result:          options[:result],
      data:            options[:data]
    }
    Activity.create(params)
  end

  def publish_session_create(record = {})
    record = @default_options.slice(:user_ip, :user_agent).merge(record)
    EventAPI.notify('system.session.create', record: record)
  end

end
