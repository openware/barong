# frozen_string_literal: true

# json formatter for logs
class JSONLogFormatter < ::Logger::Formatter
  def call(severity, time, _progname, msg)
    JSON.dump(level: severity, time: time, message: msg) + "\n"
  end
end
