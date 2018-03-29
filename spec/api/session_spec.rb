require 'spec_helper'

describe 'Session create test' do
  describe 'POST /api/session/create', if: ENV['CHROME_DEBUG'].in?(%w[ 1 true ]) do
    let!(:email) { 'user@barong.io' }
    let!(:password) { 'testpassword111' }
    let(:uri) { '/api/session/create' }
    let(:check_uri) { '/api/security/renew' }
    let!(:application) { create :doorkeeper_application }
    subject!(:acc) do
      create :account,
      email: email,
      password: password,
      password_confirmation: password
    end

    it 'Checks if current credentials are valid and returns valid JWT' do
      post uri, params: { email: email, password: password, application_id: application.uid }
      expect(response.status).to eq(201)

      post check_uri,
           headers: { Authorization: "Bearer #{JSON.parse(response.body)}" }
      expect(response.status).to eq(201)
    end

    it 'Checks if current credentials are valid and returns error, cause they are not' do
      post uri
      expect(response.status).to eq(401)
      expect(response.body).to eq("{\"error\":\"401 Unauthorized\"}")

      post uri, params: { email: 'rick@morty.io', password: 'season1' }
      expect(response.status).to eq(401)
      expect(response.body).to eq("{\"error\":\"401 Unauthorized\"}")

      post uri, params: { email: email }
      expect(response.status).to eq(401)
      expect(response.body).to eq("{\"error\":\"401 Unauthorized Application\"}")

      post uri, params: { email: email, password: password}
      expect(response.status).to eq(401)
      expect(response.body).to eq("{\"error\":\"401 Unauthorized Application\"}")
    end
  end
end
