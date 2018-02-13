if Rails.application.secrets.google_storage_bucket
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'Google',
      google_json_key_string: Rails.application.secrets.google_json_key_string
    }

    config.fog_directory = Rails.application.secrets.google_storage_bucket
  end
end
