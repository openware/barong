# frozen_string_literal: true

# It's for upload document for Document model
class UploadUploader < CarrierWave::Uploader::Base
  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    Barong::App.config.upload_extension_whitelist
  end

  def size_range
    # default is 1..10.megabytes
    Barong::App.config.upload_size_min_range..Barong::App.config.upload_size_max_range.megabytes
  end

  # Override default 'publicly visible' policy of fog
  def fog_public
    false # (default is true, which is not recommended for KYC documents or any user info
  end

  # Set the expire time of authentification signature
  def fog_authenticated_url_expiration
    Barong::App.config.upload_auth_url_expiration.minutes # (default is 1.minute)
  end
end
