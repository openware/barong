# frozen_string_literal: true

require 'ostruct'
require 'econfig/active_record'

module Econfig
  class ActiveRecord
    class Option < ::ActiveRecord::Base
      self.table_name = 'config_settings'
      serialize :value
    end

    def has_key?(key)
      Option.exists?(key: key.to_s)
    end

    def get(key)
      Option.find_by(key: key).yield_self do |option|
        if option.present? and option.value.is_a?(Hash)
          OpenStruct.new(option.value)
        else
          option&.value
        end
      end
    end
  end

  class YAML
    def get(key)
      if options[key].present? and options[key].is_a?(Hash)
        OpenStruct.new(options[key])
      else
        options[key]
      end

    end
  end

  module Services
    class SetupBackends
      # NOTE: setup backends in order the will be searched 
      def self.execute
        %i(memory env secrets db yaml).each do |backend|
          Econfig.backends.delete(backend) if Econfig.backends.send(:index_of, backend).present?
        end
        Econfig.backends.push :env, Econfig::ENV.new
        Econfig.backends.push :secrets, Econfig::YAML.new('config/secrets.yml')
        Econfig.backends.push :db, Econfig::ActiveRecord.new
        Econfig.backends.push :yaml, Econfig::YAML.new('config/config_settings_seed.yml')
        Econfig.default_write_backend = :db
      end
    end
    
    class ConfigSettingsSeed
      #NOTE: popultae :db backend from :yaml backend
      def self.execute
        Econfig.backends[:yaml].send(:options).each do |key, value|
          Econfig.backends[:db].set(key, value)
        end
      end
    end
  end
end

if ActiveRecord::Base.connection.table_exists?(Econfig::ActiveRecord::Option.table_name)
  Econfig::Services::SetupBackends.execute
  Econfig::Services::ConfigSettingsSeed.execute
else
  Econfig::Services::SetupBackends.execute
  Econfig.backends.delete(:db)
end
