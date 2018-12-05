# frozen_string_literal: true

require 'spec_helper'

describe 'Documents API test' do
  include_context 'bearer authentication'

  let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }

  describe 'POST /api/v2/resource/documents/' do
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
        post '/api/v2/resource/documents', headers: auth_header,
                                  params: {
                                    doc_type: 'Passport',
                                    doc_expire: '2020-01-22',
                                    doc_number: 'AA1234BB',
                                    attachments: [
                                      fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                    ]
                                  }
      end

      expect(response.status).to eq(201)
    end

    it 'renders an error when max documents was reached' do
      11.times do
        post '/api/v2/resource/documents', headers: auth_header,
                                  params: {
                                    doc_type: 'Passport',
                                    doc_expire: '2020-01-22',
                                    doc_number: 'AA1234BB',
                                    attachments: [
                                      fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                    ]
                                  }
      end

      expect(response.status).to eq(400)
      expect_body.to eq(error: 'Maximum number of documents was reached')
    end

    it 'Checks if params are ok and returns success' do
      post '/api/v2/resource/documents', headers: auth_header, params: params
      expect(response.status).to eq(201)
    end

    it 'Creates document with optional params and returns success' do
      post '/api/v2/resource/documents', headers: auth_header, params: params.merge(optional_params)
      expect(response.status).to eq(201)
      expect(last_document.metadata.symbolize_keys).to eq(optional_params[:metadata])
    end

    it 'Checks provided params and returns error, cause some of them are not valid or absent' do
      post '/api/v2/resource/documents', params: params.except(:doc_type), headers: auth_header
      expect_body.to eq(error: 'doc_type is missing, doc_type is empty')
      expect(response.status).to eq(400)

      post '/api/v2/resource/documents', params: params.except(:doc_expire), headers: auth_header
      expect_body.to eq(error: 'doc_expire is missing, doc_expire is empty')
      expect(response.status).to eq(400)

      post '/api/v2/resource/documents', params: params.except(:doc_number), headers: auth_header
      expect_body.to eq(error: 'doc_number is missing, doc_number is empty')
      expect(response.status).to eq(400)

      post '/api/v2/resource/documents', params: params.except(:upload), headers: auth_header
      expect_body.to eq(error: 'upload is missing, upload is empty')
      expect(response.status).to eq(400)

      params0 = params
      params0[:upload] = Faker::Avatar.image
      post '/api/v2/resource/documents', params: params0, headers: auth_header
      expect_body.to eq(error: 'upload is invalid')
      expect(response.status).to eq(400)
    end

    it 'Returns user all his documents' do
      post '/api/v2/resource/documents', params: params, headers: auth_header
      expect(response.status).to eq(201)

      get '/api/v2/resource/documents', headers: auth_header
      response_arr = JSON.parse(response.body)
      expect(response_arr.count).to eq(1)
      expect(response_arr.last['upload']).to_not be_nil
      expect(response_arr.last['doc_type']).to eq('Passport')
      expect(response_arr.last['doc_expire']).to eq('2020-01-22')
      expect(response_arr.last['doc_number']).to eq('AA1234BB')
      expect(response.status).to eq(200)
    end

    it 'Returns error without token' do
      post '/api/v2/resource/documents', params: params
      expect(response.status).to eq(401)

      get '/api/v2/resource/documents', params: params
      expect(response.status).to eq(401)
    end
    after(:all) { User.destroy_all }
  end
end
