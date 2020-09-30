# frozen_string_literal: true

require 'bunny'
require 'ostruct'

class EventMailer
  def initialize(events, exchanges, keychain)
    @exchanges = exchanges
    @keychain = keychain
    @events = events

    Kernel.at_exit { unlisten }
  end

  def call
    listen
  end

  private

  def listen
    unlisten

    @bunny_session = Bunny::Session.new(rabbitmq_credentials).tap do |session|
      session.start
      Kernel.at_exit { session.stop }
    end

    @bunny_channel = @bunny_session.channel

    queue = @bunny_channel.queue('barong.postmaster.event.mailer', auto_delete: false, durable: true)
    @events.each do |event|
      exchange = @bunny_channel.direct(@exchanges[event[:exchange].to_sym][:name])
      queue.bind(exchange, routing_key: event[:key])
    end

    Rails.logger.info { 'Listening for events.' }
    queue.subscribe(manual_ack: false, block: true, &method(:handle_message))
  end

  def unlisten
    if @bunny_session || @bunny_channel
      Rails.logger.info { 'No longer listening for events.' }
    end

    @bunny_channel&.work_pool&.kill
    @bunny_session&.stop
  ensure
    @bunny_channel = nil
    @bunny_session = nil
  end

  def algorithm_verification_options(signer)
    { algorithms: @keychain[signer][:algorithm] }
  end

  def jwt_public_key(signer)
    OpenSSL::PKey.read(Base64.urlsafe_decode64(@keychain[signer][:value]))
  end

  def rabbitmq_credentials
    if Barong::App.config.event_api_rabbitmq_url.present?
      Barong::App.config.event_api_rabbitmq_url
    else
      {
        host: Barong::App.config.event_api_rabbitmq_host,
        port: Barong::App.config.event_api_rabbitmq_port,
        username: Barong::App.config.event_api_rabbitmq_username,
        password: Barong::App.config.event_api_rabbitmq_password
      }
    end
  end

  def handle_message(delivery_info, _metadata, payload)
    exchange    = @exchanges.select { |_, ex| ex[:name] == delivery_info[:exchange] }
    exchange_id = exchange.keys.first.to_s
    signer      = exchange[exchange_id.to_sym][:signer]

    result = verify_jwt(payload, signer.to_sym)

    raise "Failed to verify signature from #{signer}." \
      unless result[:verified].include?(signer.to_sym)

    config = @events.select do |event|
      event[:key] == delivery_info[:routing_key] &&
        event[:exchange] == exchange_id
    end.first

    event = result[:payload].fetch(:event)
    obj   = JSON.parse(event.to_json, object_class: OpenStruct)

    user  = User.includes(:profiles).find_by(uid: obj.record.user.uid)
    language = user.language.to_sym

    unless config[:templates].key?(language)
      Rails.logger.error { "Language #{language} is not supported. Skipping." }
      return
    end

    if config[:expression].present? && skip_event(event, config[:expression])
      Rails.logger.info { "Event #{obj.name} skipped" }
      return
    end

    params = {
      logo: Barong::App.config.smtp_logo_link,
      subject: config[:templates][language][:subject],
      template_name: config[:templates][language][:template_path],
      record: obj.record,
      changes: obj.changes,
      user: user
    }

    Postmaster.process_payload(params).deliver_now
  rescue StandardError => e
    Rails.logger.error { e.inspect }

    unlisten if db_connection_error?(e)
  end

  def verify_jwt(payload, signer)
    options = algorithm_verification_options(signer)
    JWT::Multisig.verify_jwt JSON.parse(payload), { signer => jwt_public_key(signer) },
                             options.compact
  end

  def skip_event(event, expression)
    # valid operators: and / or / not
    operator = expression.keys.first.downcase
    # { field_name: field_value }
    values = expression[operator]

    # return array of boolean [false, true]
    res = values.keys.map do |field_name|
      safe_dig(event, field_name.to_s.split('.')) == values[field_name]
    end

    # all? works as AND operator, any? works as OR operator
    return false if (operator == :and && res.all?) || (operator == :or && res.any?) ||
                    (operator == :not && !res.all?)

    return true if operator == :not && res.all?

    true
  end

  def db_connection_error?(exception)
    exception.is_a?(Mysql2::Error::ConnectionError) || exception.cause.is_a?(Mysql2::Error)
  end

  def safe_dig(hash, keypath, default = nil)
    stringified_hash = JSON.parse(hash.to_json)
    stringified_keypath = keypath.map(&:to_s)

    stringified_keypath.reduce(stringified_hash) do |accessible, key|
      return default unless accessible.is_a? Hash
      return default unless accessible.key? key

      accessible[key]
    end
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end
end
