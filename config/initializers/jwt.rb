require 'yaml'
require 'openssl'

(YAML.load_file('config/management_api.yml') || {}).deep_symbolize_keys!.tap do |x|
  x.fetch(:keychain).each do |id, key|
    key = OpenSSL::PKey.read(Base64.urlsafe_decode64(key.fetch(:value)))
    if key.private?
      raise ArgumentError, 'keychain.' + id.to_s + ' was set to private key, ' \
        'however it should be public (in config/management_api.yml).'
    end
    x[:keychain][id][:value] = key
  end

  x.fetch(:scopes).values.each do |scope|
    %i[permitted_signers mandatory_signers].each do |list|
      scope[list] = scope.fetch(list, []).map(&:to_sym)
      scope[list] = scope.fetch(list, []).map(&:to_sym)
      if list == :mandatory_signers && scope[list].empty?
        raise ArgumentError, 'scopes.' + scope.to_s + '.' + list.to_s + ' is empty, ' \
          'however it should contain at least one value (in config/management_api.yml).'
      end
    end
  end

  API::V2::Management::JWTAuthenticationMiddleware.security_configuration = x
end
