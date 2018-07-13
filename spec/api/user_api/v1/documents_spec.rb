# frozen_string_literal: true

require 'spec_helper'

describe 'Documents API test' do
  include_context 'doorkeeper authentication'
  let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }

  describe 'POST /api/v1/documents/' do
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

    let(:last_document) { Document.last }

    it 'saves 10 documents successfully' do
      10.times do
        post '/api/v1/documents', headers: auth_header,
                                  params: {
                                    doc_type: 'Passport',
                                    doc_expire: '2020-01-22',
                                    doc_number: 'AA1234BB',
                                    upload: fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                  }
      end

      expect(response.status).to eq(201)
    end

    it 'renders an error when max documents was reached' do
      11.times do
        post '/api/v1/documents', headers: auth_header,
                                  params: {
                                    doc_type: 'Passport',
                                    doc_expire: '2020-01-22',
                                    doc_number: 'AA1234BB',
                                    upload: fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                  }
      end

      expect(response.status).to eq(400)
      expect_body.to eq(error: 'Maximum number of documents was reached')
    end

    it 'Checks if params are ok and returns success' do
      post '/api/v1/documents', headers: auth_header, params: params
      expect(response.status).to eq(201)
    end

    it 'Creates document with optional params and returns success' do
      post '/api/v1/documents', headers: auth_header, params: params.merge(optional_params)
      expect(response.status).to eq(201)
      expect(last_document.metadata.symbolize_keys).to eq(optional_params[:metadata])
    end

    it 'Checks provided params and returns error, cause some of them are not valid or absent' do
      post '/api/v1/documents', params: params.except(:doc_type), headers: auth_header
      expect_body.to eq(error: 'Document Type is missing, Document Type is empty')
      expect(response.status).to eq(400)

      post '/api/v1/documents', params: params.except(:doc_expire), headers: auth_header
      expect_body.to eq(error: 'Document Expire is missing, Document Expire is empty')
      expect(response.status).to eq(400)

      post '/api/v1/documents', params: params.except(:doc_number), headers: auth_header
      expect_body.to eq(error: 'Document Number is missing, Document Number is empty')
      expect(response.status).to eq(400)

      post '/api/v1/documents', params: params.except(:upload), headers: auth_header
      expect_body.to eq(error: 'Image is missing, Image is empty')
      expect(response.status).to eq(400)

      params0 = params
      params0[:upload] = Faker::Avatar.image
      post '/api/v1/documents', params: params0, headers: auth_header
      expect_body.to eq(error: 'Image is invalid')
      expect(response.status).to eq(400)
    end

    it 'Returns user all his documents' do
      post '/api/v1/documents', params: params, headers: auth_header
      expect(response.status).to eq(201)

      get '/api/v1/documents', headers: auth_header
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
      expect_body.to eq(error: 'The access token is invalid')
      expect(response.status).to eq(401)

      get '/api/v1/documents', params: params
      expect_body.to eq(error: 'The access token is invalid')
      expect(response.status).to eq(401)
    end
    after(:all) { Account.destroy_all }
  end
end
