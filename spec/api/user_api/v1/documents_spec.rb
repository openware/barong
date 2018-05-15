# frozen_string_literal: true

require 'spec_helper'

describe 'Documents API test' do
  describe 'POST /api/v1/documents/' do
    let!(:account) { create :account }
    let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }
    subject!(:access_token) { create :doorkeeper_token, resource_owner_id: account.id }
    let(:headers) do
      { Authorization: "Bearer #{access_token.token}" }
    end
    let(:params) do
      {
        doc_type: 'Passport',
        doc_expire: '2020-01-22',
        doc_number: 'AA1234BB',
        upload: image
      }
    end

    let!(:optional_params) do
      {
        metadata: {
          country: Faker::Address.country
        }
      }
    end

    it 'Checks if params are ok and returns success' do
      post '/api/v1/documents', headers: headers, params: params
      expect(response.status).to eq(201)
    end

    it 'Creates document with optional params and returns success' do
      post '/api/v1/documents', headers: headers, params: params.merge(optional_params)
      expect(response.status).to eq(201)
      document = Document.last
      expect(document).to be
      expect(document.metadata.symbolize_keys).to eq(optional_params[:metadata])
    end

    it 'Checks provided params and returns error, cause some of them are not valid or absent' do
      post '/api/v1/documents', params: params.except(:doc_type), headers: headers
      expect(response.body).to eq('{"error":"doc_type is missing"}')
      expect(response.status).to eq(400)

      post '/api/v1/documents', params: params.except(:doc_expire), headers: headers
      expect(response.body).to eq('{"error":"doc_expire is missing"}')
      expect(response.status).to eq(400)

      post '/api/v1/documents', params: params.except(:doc_number), headers: headers
      expect(response.body).to eq('{"error":"doc_number is missing"}')
      expect(response.status).to eq(400)

      post '/api/v1/documents', params: params.except(:upload), headers: headers
      expect(response.body).to eq('{"error":"upload is missing"}')
      expect(response.status).to eq(400)

      params0 = params
      params0[:upload] = Faker::Avatar.image
      post '/api/v1/documents', params: params0, headers: headers
      expect(response.body).to eq('{"error":"Upload can\'t be blank"}')
      expect(response.status).to eq(400)
    end

    it 'Returns user all his documents' do
      post '/api/v1/documents', params: params, headers: headers
      expect(response.status).to eq(201)

      get '/api/v1/documents', headers: headers
      response_arr = JSON.parse(response.body)
      expect(response_arr.count).to eq(1)
      expect(response_arr.last['upload']).to_not be_nil
      expect(response_arr.last['doc_type']).to eq('Passport')
      expect(response_arr.last['doc_expire']).to eq('2020-01-22')
      expect(response_arr.last['doc_number']).to eq('AA1234BB')
      expect(response.status).to eq(200)
    end

    it 'Returns error, cause token is not valid' do
      post '/api/v1/documents', params: params
      expect(response.body).to eq('{"error":"The access token is invalid"}')
      expect(response.status).to eq(401)

      get '/api/v1/documents', params: params
      expect(response.body).to eq('{"error":"The access token is invalid"}')
      expect(response.status).to eq(401)
    end
    after(:all) { Account.destroy_all }
  end
end
