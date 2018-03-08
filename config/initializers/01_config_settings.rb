# frozen_string_literal: true

require 'econfig/active_record'
require Rails.root.join('config/config_settings_casts').to_s

module Econfig
  class ActiveRecord
    class Option < ::ActiveRecord::Base
      self.table_name = 'config_settings'
      serialize :value
    end
  end

  module Services
    class SetupBackends
      # NOTE: setup backends in order they will be searched for key-value
      def self.execute
        %i(memory env secrets db yaml).each do |backend_name|
          Econfig.backends.delete(backend_name) if Econfig.backends.send(:index_of, backend_name).present?
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

Econfig::Services::SetupBackends.execute

if ActiveRecord::Base.connection.table_exists?(Econfig::ActiveRecord::Option.table_name)
  unless Econfig::ActiveRecord::Option.exists?
    Econfig::Services::ConfigSettingsSeed.execute
  end
else
  Econfig.backends.delete(:db)
end
