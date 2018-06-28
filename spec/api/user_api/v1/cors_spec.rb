# frozen_string_literal: true

describe 'CORS', type: :request do
  include_context 'doorkeeper authentication'

  def expect_valid_cors(response)
    expect(response.headers['Access-Control-Allow-Origin']).to eq('https://frontend.barong.io')
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
    expect(response.headers['Access-Control-Allow-Headers']).to eq('Origin, X-Requested-With, Content-Type, Accept, Authorization')
    expect(response.headers['Access-Control-Allow-Credentials']).to eq('false')
  end

  context 'when origin env is empty' do
    before { ENV['API_CORS_ORIGINS'] = nil }

    it 'sends CORS headers when requesting using GET' do
      get '/api/v1/accounts/me', headers: auth_header
      expect(response).to be_success
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end

  context 'when origins env is a domain' do
    before { ENV['API_CORS_ORIGINS'] = 'https://frontend.barong.io' }

    it 'sends CORS headers when requesting using OPTIONS' do
      reset! unless integration_session
      integration_session.send :process, 'OPTIONS', '/api/v1/accounts/me'
      expect(response).to be_success
      expect_valid_cors(response)
    end

    it 'sends CORS headers when requesting using GET' do
      get '/api/v1/accounts/me', headers: auth_header
      expect(response).to be_success
      expect_valid_cors(response)
    end

    it 'sends CORS headers ever when user is not authenticated' do
      get '/api/v1/accounts/me'
      expect(response).to have_http_status 401
      expect_valid_cors(response)
    end

    it 'sends CORS headers when invalid parameter supplied' do
      post '/api/v1/accounts', params: {}
      expect(response).to have_http_status 400
      expect_valid_cors(response)
    end
  end
end
