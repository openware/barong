# frozen_string_literal: true

class APIKeysVerifier

  def initialize(params = {})
    @kid = params[:kid]
    @signature = params[:signature]
    @nonce = params[:nonce] || nil
    @api_key = APIKey.active.find_by!(kid: @kid)
  end

  def verify_hmac_payload?
    data = @nonce.to_s + @kid
    secret = APISecretsStorage.get_secret(@kid)
    algorithm = 'SHA' + @api_key.algorithm[2..4]
    true_signature = OpenSSL::HMAC.hexdigest(algorithm, secret, data)
    true_signature == @signature
  end
end
