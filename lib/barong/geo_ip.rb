# frozen_string_literal: true

module Barong
# MaxmindDB reader adapter
  module GeoIP
    class << self
      attr_accessor :lang

      # Usage: country, city = Barong::GeoIP.info(request_ip, :country, :city)
      def info(ip, *keys)
        record = reader.get(ip)
        keys.map { |key| fetch(record, key) }
      end

      # Usage: city = Barong::GeoIP.get(ip: ip, key: :city)
      def get(ip:, key:)
        fetch(reader.get(ip), key)
      end

    private
      def reader
        @reader ||= MaxMind::DB.new(Barong::App.config.barong_maxminddb_path, mode: MaxMind::DB::MODE_MEMORY)
      end

      def fetch(record, key)
        return unless record

        case key.to_sym
        when :country
          return country(record)
        when :continent
          return continent(record)
        when :city
          return city(record)
        end
      end

      def country(record)
        record['country']['names'][lang] if record['country']
      end

      def continent(record)
        record['continent']['names'][lang] if record['continent']
      end

      def city(record)
        if record['city']
          record['city']['names'][lang]
        elsif record['subdivisions']
          record['subdivisions'].first['names'][lang]
        else
          nil
        end
      end
    end
  end
end
