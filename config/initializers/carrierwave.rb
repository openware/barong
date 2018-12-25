# frozen_string_literal: true

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if 'Google'.casecmp(Rails.application.secrets.storage_provider) == 0
    config.fog_provider = 'fog/google'
    config.fog_credentials = {
      provider: 'Google',
      google_storage_access_key_id: Rails.application.secrets.storage_access_key,
      google_storage_secret_access_key: Rails.application.secrets.storage_secret_key
    }
    config.fog_directory = Rails.application.secrets.storage_bucket_name
  elsif 'AWS'.casecmp(Rails.application.secrets.storage_provider) == 0
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.application.secrets.storage_access_key,
      aws_secret_access_key: Rails.application.secrets.storage_secret_key,
      region: Rails.application.secrets.storage_region
    }
    config.fog_directory = Rails.application.secrets.storage_bucket_name
  else
    config.storage :file
  end
end
