# frozen_string_literal: true

namespace 'migrate' do
  desc 'Migrate api keys from vault secrets to transit'
  task "26-api-keys": [:environment] do
    puts 'Migrating API keys from secrets to transit keys (new in 2.6)'
    APIKey.find_in_batches do |keys|
      keys.each do |key|
        legacy_key_path = "secret/barong/api_key/#{key.kid}"
        secret = TOTPService.read_data(legacy_key_path)
        next unless secret

        value = secret.data[:value]
        next unless value

        key.secret = value
        key.save!
        TOTPService.delete_data(legacy_key_path)
      end
    end
  end

  desc 'Move TOTP secrets to include the vault application as prefix'
  task "26-totp": [:environment] do
    puts 'Moving TOTP secrets to include the vault application as prefix (new in 2.6)'

    User.find_in_batches do |users|
      users.each do |u|
        legacy_key_path = "totp/keys/#{u.uid}"
        legacy_export_path = "totp/export/#{u.uid}"

        next unless TOTPService.read_data(legacy_key_path)

        params = TOTPService.read_data(legacy_export_path)
        unless params
          raise "Failed to export key (#{legacy_export_path})\n"\
          "Make sure vault is running with this image: quay.io/openware/vault:1.5.3-openware\n"\
          'And make sure the token has read access to /totp/export/*'
        end
        key_path = TOTPService.totp_key(u.uid)
        TOTPService.write_data(key_path, params.data.merge(generate: false))
        TOTPService.delete_data(legacy_key_path)
      end
    end
  end
end
