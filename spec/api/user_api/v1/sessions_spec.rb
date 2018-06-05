# frozen_string_literal: true

describe 'Session create test' do
  describe 'POST /api/v1/sessions' do
    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
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
          expect_body.to eq(error: 'Email is missing, Password is missing, Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when Application ID is missing' do
          post uri, params: { email: 'rick@morty.io', password: 'season1' }
          expect_body.to eq(error: 'Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when password and Application ID is missing' do
          post uri, params: { email: email }
          expect_body.to eq(error: 'Password is missing, Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when Application ID is missing' do
          post uri, params: { email: email, password: password }
          expect_body.to eq(error: 'Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when Password is wrong' do
          post uri, params: { email: email, password: 'password', application_id: application.uid }
          expect_body.to eq(error: 'Invalid Email or Password')
          expect(response.status).to eq(401)
        end

        it 'when Application ID is wrong' do
          post uri, params: { email: email, password: password, application_id: 'application.uid' }
          expect_body.to eq(error: 'Wrong Application ID')
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
          expect_body.to eq(error: 'You have to confirm your email address before continuing.')
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe 'POST /api/v1/sessions/generate_jwt' do
    let(:do_request) do
      post '/api/v1/sessions/generate_jwt', params: params
    end
    let(:params) { {} }
    let!(:account) { create(:account) }
    let!(:api_key) do
      create(:api_key, account: account,
                       public_key: jwt_keypair_encoded[:public])
    end

    context 'when required params are missing' do
      it 'renders an error' do
        do_request
        expect_status.to eq 400
        expect_body.to eq(error: 'KID is missing, KID is empty, JWT Token is missing, JWT Token is empty')
      end
    end

    context 'when key is not found' do
      let(:params) do
        {
          kid: 'invalid',
          jwt_token: 'invalid_token'
        }
      end
      it 'renders an error' do
        do_request
        expect_status.to eq 404
        expect_body.to eq(error: 'Record is not found')
      end
    end

    context 'when payload is invalid' do
      let(:params) do
        {
          kid: api_key.uid,
          jwt_token: 'invalid_token'
        }
      end
      it 'renders an error' do
        do_request
        expect_status.to eq 401
        expect(json_body[:error]).to include('Failed to decode and verify JWT')
      end
    end

    context 'when payload is valid' do
      let(:params) do
        {
          kid: api_key.uid,
          jwt_token: encode_api_key_payload({})
        }
      end
      let(:expected_payload) do
        {
          sub: 'session',
          iss: 'barong',
          aud: api_key.scopes,
          email: account.email,
          level: account.level,
          role: account.role,
          state: account.state
        }
      end

      before do
        expect(Rails.application.secrets).to \
          receive(:jwt_shared_secret_key) { jwt_keypair_encoded[:private] }
        do_request
      end

      it { expect_status.to eq 200 }
      it 'generates valid session jwt' do
        token = json_body[:token]
        payload, = jwt_decode(token)

        expect(payload.symbolize_keys).to include(expected_payload)
      end
    end
  end
end
