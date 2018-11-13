# frozen_string_literal: true

shared_context 'bearer authentication' do

  let(:test_user) { create(:user) }

  let(:jwt_token) do
    pkey = Rails.application.config.x.keystore.private_key
    codec = Barong::JWT.new(key: pkey)
    codec.encode(test_user.as_payload)
  end

  let(:auth_header) { { 'Authorization' => "Bearer #{jwt_token}" } }
end
