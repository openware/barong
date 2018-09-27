# frozen_string_literal: true

describe 'CORS', type: :request do
  include_context 'doorkeeper authentication'

  let(:ranger_url) { 'https://ranger.barong.io' }
  let(:frontend_url) { 'https://frontend.barong.io' }
  let(:origin_header) { { 'Origin' => ranger_url } }
  let(:allowed_headers) do
    'Origin, X-Requested-With, Content-Type, Accept, Authorization, Set-Cookie'
  end

  context 'when API_CORS_ORIGINS is not set' do
    it 'does not set cors origins' do
      ENV['API_CORS_ORIGINS'] = nil

      get '/api/v1/accounts/me', headers: auth_header.merge(origin_header)
      expect(response).to be_successful

      expect(response.headers['Access-Control-Allow-Origin']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Methods']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Headers']).to eq(nil)
    end

    it 'set cors origins if API_CORS_ALLOW_INSECURE_ORIGINS is set' do
      ENV['API_CORS_ORIGINS'] = nil
      ENV['API_CORS_ALLOW_INSECURE_ORIGINS'] = 'true'

      get '/api/v1/accounts/me', headers: auth_header.merge(origin_header)
      expect(response).to be_successful

      expect(response.headers['Access-Control-Allow-Origin']).to eq(ranger_url)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq('false')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
      expect(response.headers['Access-Control-Allow-Headers']).to eq(allowed_headers)

      ENV['API_CORS_ALLOW_INSECURE_ORIGINS'] = nil
    end
  end

  context 'when API_CORS_ORIGINS does not match origin' do
    before { ENV['API_CORS_ORIGINS'] = frontend_url }
    after { ENV['API_CORS_ORIGINS'] = nil }

    it 'does not set CORS headers with OPTIONS' do
      reset! unless integration_session
      integration_session.send :process, 'OPTIONS', '/api/v1/accounts/me', headers: origin_header
      expect(response).to be_successful

      expect(response.headers['Access-Control-Allow-Origin']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Methods']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Headers']).to eq(nil)
    end

    it 'does not set CORS headers with GET' do
      get '/api/v1/accounts/me', headers: auth_header.merge(origin_header)
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Origin']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Methods']).to eq(nil)
      expect(response.headers['Access-Control-Allow-Headers']).to eq(nil)
    end
  end

  context 'when API_CORS_ORIGINS matches origin' do
    before do
      ENV['API_CORS_ORIGINS'] = "#{ranger_url}, #{frontend_url}"
      ENV['API_CORS_ALLOW_CREDENTIALS'] = 'true'
    end

    after do
      ENV['API_CORS_ORIGINS'] = nil
      ENV['API_CORS_ALLOW_CREDENTIALS'] = nil
    end

    it 'sends CORS headers when requesting using OPTIONS' do
      reset! unless integration_session
      integration_session.send :process, 'OPTIONS', '/api/v1/accounts/me', headers: origin_header
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Origin']).to eq(ranger_url)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq('true')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
      expect(response.headers['Access-Control-Allow-Headers']).to eq(allowed_headers)
    end

    it 'sends CORS headers when requesting using GET' do
      get '/api/v1/accounts/me', headers: auth_header.merge(origin_header)
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Origin']).to eq(ranger_url)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq('true')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
      expect(response.headers['Access-Control-Allow-Headers']).to eq(allowed_headers)
    end

    it 'sends CORS headers ever when user is not authenticated' do
      get '/api/v1/accounts/me', headers: origin_header
      expect(response).to have_http_status 401
      expect(response.headers['Access-Control-Allow-Origin']).to eq(ranger_url)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq('true')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
      expect(response.headers['Access-Control-Allow-Headers']).to eq(allowed_headers)
    end

    it 'sends CORS headers when invalid parameter supplied' do
      post '/api/v1/accounts', params: {}, headers: origin_header
      expect(response).to have_http_status 400
      expect(response.headers['Access-Control-Allow-Origin']).to eq(ranger_url)
      expect(response.headers['Access-Control-Allow-Credentials']).to eq('true')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
      expect(response.headers['Access-Control-Allow-Headers']).to eq(allowed_headers)
    end
  end
end
