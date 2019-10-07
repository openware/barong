# frozen_string_literal: true

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

Barong::App.define do |config|
  config.set(:storage_provider, 'local')
  config.set(:storage_bucket_name, 'local')
  config.set(:storage_access_key, '')
  config.set(:storage_secret_key, '')
  config.set(:storage_endpoint, '') # optional (AWS, AliCloud)
  config.set(:storage_signature_version, '4', type: :integer) # optional (AWS)
  config.set(:storage_region, '') # optional (AWS, AliCloud)
  config.write(:uploader, UploadUploader)
end

CarrierWave.configure do |config|
  if 'Google'.casecmp(Barong::App.config.storage_provider) == 0
    config.fog_provider = 'fog/google'
    config.fog_credentials = {
      provider: 'Google',
      google_storage_access_key_id: Barong::App.config.storage_access_key,
      google_storage_secret_access_key: Barong::App.config.storage_secret_key
    }
    config.fog_directory = Barong::App.config.storage_bucket_name
  elsif 'AWS'.casecmp(Barong::App.config.storage_provider) == 0
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_signature_version: Barong::App.config.storage_signature_version,
      aws_access_key_id: Barong::App.config.storage_access_key,
      aws_secret_access_key: Barong::App.config.storage_secret_key,
      region: Barong::App.config.storage_region,
      endpoint: Barong::App.config.storage_endpoint
    }
    config.fog_directory = Barong::App.config.storage_bucket_name
  else
    config.storage :file
  end
end
