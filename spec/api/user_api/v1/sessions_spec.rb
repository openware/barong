# frozen_string_literal: true

describe 'Session create test' do
  describe 'POST /api/v1/sessions' do
    let!(:email) { 'user@barong.io' }
    let!(:password) { 'testpassword111' }
    let(:uri) { '/api/v1/sessions' }
    let(:check_uri) { '/api/v1/security/renew' }
    let!(:current_account) do
      create :account,
             email: email,
             password: password,
             password_confirmation: password
    end

    it 'Checks if current credentials are valid and returns valid JWT' do
      post uri, params: { email: email, password: password }
      expect(response.status).to eq(201)
      response_jwt = JSON.parse(response.body)

      post check_uri,
           headers: { Authorization: "Bearer #{response_jwt}" }
      expect(response.status).to eq(201)
    end

    it 'Checks if current credentials are valid and returns error, cause they are not' do
      post uri
      expect_body.to eq(error: 'email is missing, email is empty, password is missing, password is empty')
      expect(response.status).to eq(400)

      post uri, params: { email: email }
      expect(response.body).to eq('{"error":"password is missing, password is empty"}')
      expect(response.status).to eq(400)

      post uri, params: { email: email, password: 'password' }
      expect(response.body).to eq('{"error":"Invalid Email or password."}')
      expect(response.status).to eq(401)
    end
  end
end
