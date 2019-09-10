# frozen_string_literal: true

require 'aliyun/oss'

class AliUploader < UploadUploader
  def url
    bucket.object_url(Barong::App.config.storage_bucket_name + '/' + path)
  end

  def bucket
    @_bucket = client.get_bucket(Barong::App.config.storage_bucket_name)
  end

  def client
    @_client ||= Aliyun::OSS::Client.new(
      endpoint:          "oss-#{Barong::App.config.storage_region}.aliyuncs.com",
      access_key_id:     Barong::App.config.storage_access_key,
      access_key_secret: Barong::App.config.storage_secret_key,
    )
  end
end
