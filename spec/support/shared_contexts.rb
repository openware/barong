# frozen_string_literal: true

shared_context 'bearer authentication' do
  let!(:current_account) { create(:account) }
  let(:jwt_token) do
    jwt_encode(
      iat: Time.current.to_i,
      exp: 2.minutes.from_now.to_i,
      sub: 'session',
      iss: 'barong',
      aud: 'peatio barong',
      jti: SecureRandom.hex(12).upcase,
      uid: current_account.uid
    )
  end

  let(:auth_header) { { 'Authorization' => "Bearer #{jwt_token}" } }
end
