# frozen_string_literal: true

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if Rails.application.secrets.storage_provider.eql? 'Google'
    config.fog_credentials = {
      provider: 'Google',
      google_storage_access_key_id: Rails.application.secrets.storage_access_key,
      google_storage_secret_access_key: Rails.application.secrets.storage_secret_key
    }
    config.fog_directory = Rails.application.secrets.storage_bucket_name
  elsif Rails.application.secrets.storage_provider.eql? 'AWS'
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
