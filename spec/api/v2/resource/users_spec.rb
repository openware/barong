# frozen_string_literal: true

require_dependency 'barong/jwt'

describe 'Api::V1::Profiles' do
  include_context 'bearer authentication'

  describe 'GET /api/v2/users/me' do
    it 'should reply permissions denied' do
      get '/api/v2/users/me'
      expect(json_body[:error][:code]).to eq(2001)
      expect(response.status).to eq(401)
    end

    it 'should allow traffic with Authorization' do
      get '/api/v2/users/me', headers: auth_header
      expect(json_body[:email]).to eq(test_user.email)
      expect(response.status).to eq(200)
    end
  end
end
