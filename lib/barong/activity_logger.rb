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
            params = format_params(msg)
            Rails.logger.info("Recording activity for user id: #{params[:user_id]}, topic: #{params[:topic]}," \
                              " action: #{params[:action]}, result: #{params[:result]}, data: #{params[:data]}")
            Activity.create(params)
          rescue StandardError => e
            Rails.logger.error { "Failed to create activity with params: #{params}\n" \
                                 "Inspect error: #{e.inspect}\n#{e.backtrace.join("\n")}" }

            # If system catch Mysql2::Error::ConnectionError
            # System will reconnect to DB and push message again to the activities queue
            if e.is_a? (ActiveRecord::StatementInvalid)
              ActiveRecord::Base.connection.reconnect!
              sleep(0.1)
              @activities.push(options)
            end
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
        user_id:         params[:user_id],
        target_uid:      target_user(params[:payload]) || '',
        user_ip:         params[:user_ip],
        user_ip_country: Barong::GeoIP.info(ip: params[:user_ip], key: :country),
        user_agent:      params[:user_agent],
        topic:           topic,
        action:          ACTION[params[:verb].downcase.to_sym] || 'system',
        result:          params[:result],
        category:        'admin',
        data:            format_payload(params[:payload])
      }
    end

    def self.format_payload(payload)
      return unless payload

      return payload.to_json unless valid_json?(payload.keys.first)

      payload.keys.first
    end

    def self.target_user(payload)
      # in case payload is missing || empty POST body: payload => {"null" => nil }
      return if payload.nil? || payload.keys.first == "null"

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
