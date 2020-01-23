# frozen_string_literal: true

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

Barong::App.define do |config|
  # Storage configuration 
  # https://github.com/openware/barong/blob/master/docs/configuration.md#storage-configuration

  config.set(:storage_provider, 'local')
  config.set(:storage_bucket_name, 'local')
  config.set(:storage_access_key, '')
  config.set(:storage_secret_key, '')
  config.set(:storage_endpoint, '') # optional (AWS, AliCloud)
  config.set(:storage_signature_version, '4') # optional (AWS)
  config.set(:storage_region, '') # optional (AWS, AliCloud)
  config.set(:storage_pathstyle, 'false', type: :bool) # optional (AWS, AliCloud)
  config.write(:uploader, UploadUploader)
end

CarrierWave.configure do |config|
  if 'Google'.casecmp?(Barong::App.config.storage_provider)
    config.fog_credentials = {
      provider: 'Google',
      google_storage_access_key_id: Barong::App.config.storage_access_key,
      google_storage_secret_access_key: Barong::App.config.storage_secret_key
    }
    config.fog_directory = Barong::App.config.storage_bucket_name
  elsif 'AWS'.casecmp?(Barong::App.config.storage_provider)
    config.fog_credentials = {
      provider: 'AWS',
      aws_signature_version: Barong::App.config.storage_signature_version,
      aws_access_key_id: Barong::App.config.storage_access_key,
      aws_secret_access_key: Barong::App.config.storage_secret_key,
      region: Barong::App.config.storage_region,
      endpoint: Barong::App.config.storage_endpoint,
      path_style: Barong::App.config.storage_pathstyle
    }
    config.fog_directory = Barong::App.config.storage_bucket_name
  elsif 'AliCloud'.casecmp?(Barong::App.config.storage_provider)
    Barong::App.write(:uploader, AliUploader)
    config.fog_credentials = {
      provider:                'aliyun',
      aliyun_accesskey_id:     Barong::App.config.storage_access_key,
      aliyun_accesskey_secret: Barong::App.config.storage_secret_key,
      aliyun_oss_bucket:       Barong::App.config.storage_bucket_name,
      aliyun_region_id:        Barong::App.config.storage_region,
      aliyun_oss_endpoint:     "oss-#{Barong::App.config.storage_region}.aliyuncs.com"
    }
    config.fog_directory = Barong::App.config.storage_bucket_name
  else
    config.storage :file
  end
end
