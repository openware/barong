# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/lazy_load_hooks'

# EventAPI provides interface to platform-wide notifications in RabbitMQ.
#
# Check docs/specs/event_api.md for more details.
module EventAPI
  class << self
    def notify(event_name, event_payload)
      arguments = [event_name, event_payload]
      middlewares.each do |middleware|
        returned_value = middleware.call(*arguments)
        case returned_value
        when Array then arguments = returned_value
        else return returned_value
        end
      rescue StandardError => e
        report_exception(e)
        raise
      end
    end

    def middlewares=(list)
      @middlewares = list
    end

    def middlewares
      @middlewares ||= []
    end
  end

  module ActiveRecord
    class Mediator
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def notify(partial_event_name, event_payload)
        tokens = ['model']
        tokens << record.class.event_api_settings.fetch(:prefix) { record.class.name.underscore.gsub(/\//, '_') }
        tokens << partial_event_name.to_s
        full_event_name = tokens.join('.')

        ::EventAPI.notify(full_event_name, event_payload)
      end

      def notify_record_created
        notify(:created, record: record.as_json_for_event_api.compact)
      end

      def notify_record_updated
        return if record.previous_changes.blank?

        current_record  = record
        previous_record = record.dup
        record.previous_changes.each { |attribute, values| previous_record.send("#{attribute}=", values.first) }

        # Guarantee timestamps.
        previous_record.created_at ||= current_record.created_at
        previous_record.updated_at ||= current_record.created_at

        after  = current_record.as_json_for_event_api.compact
        before = previous_record.as_json_for_event_api.compact.delete_if { |atr, val| after[atr] == val }

        notify :updated, \
          record:  after,
          changes: before.except(:updated_at)
      end
    end

    module Extension
      extend ActiveSupport::Concern

      included do
        # We add «after_commit» callbacks immediately after inclusion.
        %i[create update].each do |event|
          after_commit on: event, prepend: true do
            if self.class.event_api_settings[:on]&.include?(event)
              event_api.public_send("notify_record_#{event}d")
            end
          end
        end
      end

      module ClassMethods
        def acts_as_eventable(settings = {})
          settings[:on] = %i[create update] unless settings.key?(:on)
          @event_api_settings = event_api_settings.merge(settings)
        end

        def event_api_settings
          @event_api_settings || superclass.instance_variable_get(:@event_api_settings) || {}
        end
      end

      def event_api
        @event_api ||= Mediator.new(self)
      end

      def as_json_for_event_api
        as_json
      end
    end
  end

  # To continue processing by further middlewares return array with event name and payload.
  # To stop processing event return any value which isn't an array.
  module Middlewares
    class << self
      def application_name
        Rails.application.class.name.split('::').first.underscore
      end

      def application_version
        "#{application_name.camelize}::VERSION".constantize
      end
    end

    class IncludeEventMetadata
      def call(event_name, event_payload)
        event_payload[:name] = event_name
        [event_name, event_payload]
      end
    end

    class GenerateJWT
      def call(event_name, event_payload)
        jwt_payload = {
          iss:   Middlewares.application_name,
          jti:   SecureRandom.uuid,
          iat:   Time.now.to_i,
          exp:   (Time.now + 1.hour).to_i,
          event: event_payload
        }
        private_key = Barong::App.config.keystore.private_key
        algorithm   = 'RS256'

        jwt         = JWT::Multisig.generate_jwt jwt_payload, \
          { Middlewares.application_name.to_sym => private_key },
          { Middlewares.application_name.to_sym => algorithm }

        [event_name, jwt]
      rescue KeyError
        raise 'No EVENT_API_JWT_PRIVATE_KEY found in env!'
      end
    end

    class PrintToScreen
      def call(event_name, event_payload)
        Rails.logger.debug do
          ['',
           'Produced new event at ' + Time.current.to_s + ': ',
           'name    = ' + event_name,
           'payload = ' + event_payload.to_json,
           ''].join("\n")
        end
        [event_name, event_payload]
      end
    end

    class PublishToRabbitMQ
      extend Memoist

      def call(event_name, event_payload)
        Rails.logger.debug do
          "\nPublishing #{routing_key(event_name)} (routing key) to #{exchange_name(event_name)} (exchange name).\n"
        end
        exchange = bunny_exchange(exchange_name(event_name))
        exchange.publish(event_payload.to_json, routing_key: routing_key(event_name))
        [event_name, event_payload]
      end

      private

      def bunny_session
        Bunny::Session.new(rabbitmq_credentials).tap do |session|
          session.start
          Kernel.at_exit { session.stop }
        end
      end
      memoize :bunny_session

      def bunny_channel
        bunny_session.channel
      end
      memoize :bunny_channel

      def bunny_exchange(name)
        bunny_channel.direct(name)
      end
      memoize :bunny_exchange

      def rabbitmq_credentials
        return ENV['EVENT_API_RABBITMQ_URL'] if ENV['EVENT_API_RABBITMQ_URL'].present?

        {
          host: Barong::App.config.event_api_rabbitmq_host,
          port: Barong::App.config.event_api_rabbitmq_port,
          username: Barong::App.config.event_api_rabbitmq_username,
          password: Barong::App.config.event_api_rabbitmq_password
        }
      end

      def exchange_name(event_name)
        "#{Middlewares.application_name}.events.#{event_name.split('.').first}"
      end

      def routing_key(event_name)
        event_name.split('.').drop(1).join('.')
      end
    end
  end

  middlewares << Middlewares::IncludeEventMetadata.new
  middlewares << Middlewares::GenerateJWT.new
  middlewares << Middlewares::PrintToScreen.new
  middlewares << Middlewares::PublishToRabbitMQ.new
end
