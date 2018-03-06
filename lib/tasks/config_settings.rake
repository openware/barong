# frozen_string_literal: true

namespace :config_settings do
  desc 'Populate config_settings table with key-value pairs'
  task seed: :environment do
    Econfig::Services::ConfigSettingsSeed.execute
  end
end
