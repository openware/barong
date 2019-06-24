# frozen_string_literal: true

module Barong
  # admin activities log writer class
  class ActivityLogger
    ACTION = { post: 'create', put: 'update', get: 'read', delete: 'delete', patch: 'update' }.freeze

    def self.async_write(options = {})
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

    def self.sync_write(options = {})
      Activity.create(format_params(options))
    end

    def self.format_params(params)
      topic = params[:topic].nil? && params[:path].split('admin/')[1].nil? ? 'general' : params[:topic] || params[:path].split('admin/')[1].split('/')[0]
      {
        user_id:       params[:user_id],
        target_uid:   target_user(params[:payload]) || '',
        user_ip:       params[:user_ip],
        user_agent:    params[:user_agent],
        topic:         topic,
        action:        ACTION[params[:verb].downcase.to_sym] || 'system',
        result:        params[:result],
        category:      'admin',
        data:          format_payload(params[:payload])
      }
    end

    def self.format_payload(payload)
      return unless payload

      return payload.to_json unless valid_json?(payload.keys.first)

      payload.keys.first
    end

    def self.target_user(payload)
      return unless payload

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
