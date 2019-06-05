# frozen_string_literal: true

module Barong
  # admin activities log writer class
  class ActivityLogger
    ACTION = { post: 'create', put: 'update', get: 'read', delete: 'delete' }.freeze

    def self.write(options = {})
      @activities ||= Queue.new
      @activities.push(options)

      @thread ||= Thread.new do
        begin
          loop do
            msg = @activities.pop
            Activity.create(format_params(msg))
          rescue => exception
            Rails.logger.error { "Failed to create activity: #{exception.inspect}" }
          end
        end
      end
    end

    def self.format_params(params)
      topic = params[:topic].nil? ? params[:path].split('admin/')[1].split('/')[0] : params[:topic]
      {
        user_id:       params[:user_id],
        target_uid:   target_user(params[:payload]) || '',
        user_ip:       params[:user_ip],
        user_agent:    params[:user_agent],
        topic:         topic,
        action:        ACTION[params[:verb].downcase.to_sym],
        result:        params[:result],
        category:      'admin'
      }
    end

    def self.target_user(payload)
      if valid_json?(payload.keys.first)
        payload = JSON.parse(payload.keys.first)
      end
      payload[:uid] || payload[:user_uid] || payload['uid'] || payload['user_uid']
    end

    def self.valid_json?(json)
      JSON.parse(json)
      true
    rescue JSON::ParserError => e
      false
    end
  end
end
