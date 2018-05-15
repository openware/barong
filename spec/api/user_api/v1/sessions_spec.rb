# frozen_string_literal: true

describe 'Session create test' do
  describe 'POST /api/v1/sessions' do
    let!(:email) { 'user@barong.io' }
    let!(:password) { 'testpassword111' }
    let(:uri) { '/api/v1/sessions' }
    let(:check_uri) { '/api/v1/security/renew' }
    let!(:application) { create :doorkeeper_application }
    subject!(:acc) do
      create :account,
             email: email,
             password: password,
             password_confirmation: password
    end

    context 'With valid params' do
      it 'Checks current credentials and returns valid JWT' do
        post uri, params: { email: email, password: password, application_id: application.uid }
        expect(response.status).to eq(201)
        response_jwt = JSON.parse(response.body)

        post check_uri,
             headers: { Authorization: "Bearer #{response_jwt}" }
        expect(response.status).to eq(201)
      end
    end

    context 'With Invalid params' do
      context 'Checks current credentials and returns error' do
        it 'when email, password and application_id are missing' do
          post uri
          expect(response.body).to eq('{"error":"email is missing, password is missing, application_id is missing"}')
          expect(response.status).to eq(400)
        end

        it 'when application_id is missing' do
          post uri, params: { email: 'rick@morty.io', password: 'season1' }
          expect(response.body).to eq('{"error":"application_id is missing"}')
          expect(response.status).to eq(400)
        end

        it 'when password and application_id is missing' do
          post uri, params: { email: email }
          expect(response.body).to eq('{"error":"password is missing, application_id is missing"}')
          expect(response.status).to eq(400)
        end

        it 'when application_id is missing' do
          post uri, params: { email: email, password: password }
          expect(response.body).to eq('{"error":"application_id is missing"}')
          expect(response.status).to eq(400)
        end

        it 'when password is wrong' do
          post uri, params: { email: email, password: 'password', application_id: application.uid }
          expect(response.body).to eq('{"error":"Invalid Email or password."}')
          expect(response.status).to eq(401)
        end

        it 'when application_id is wrong' do
          post uri, params: { email: email, password: password, application_id: 'application.uid' }
          expect(response.body).to eq('{"error":"Wrong application id"}')
          expect(response.status).to eq(401)
        end
      end

      context 'When user has not verified his email' do
        let!(:another_email) { 'email@random.com' }
        let!(:account) do
          create :account,
                 email: another_email,
                 password: password,
                 password_confirmation: password,
                 confirmed_at: nil
        end

        it 'returns error' do
          post uri, params: { email: another_email, password: password, application_id: application.uid }
          expect(response.body).to eq('{"error":"You have to confirm your email address before continuing."}')
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
