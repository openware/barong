# frozen_string_literal: true

module Barong
# MaxmindDB reader adapter
  module GeoIP
    class << self
      attr_accessor :lang

      # Usage: city = Barong::GeoIP.info(ip: ip, key: :city)
      def info(ip:, key:)
        record = reader.get(ip)
        return unless record

        case key.to_sym
        when :country
          return record['country']['names'][lang] if record['country']
        when :continent
          return record['continent']['names'][lang] if record['continent']
        end
      end

    private

      def reader
        @reader ||= MaxMind::DB.new(Barong::App.config.maxminddb_path, mode: MaxMind::DB::MODE_MEMORY)
      end
    end
  end
end
