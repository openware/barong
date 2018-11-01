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
      %w[jpg jpeg png pdf]
    end
  
    def size_range
      1..10.megabytes
    end
  end