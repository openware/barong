# frozen_string_literal: true

require 'spec_helper'

describe 'Addresses API test' do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }
  before do
    allow(Barong::App.config).to receive_messages(required_docs_expire: false)
  end

  describe 'POST /api/v2/resource/addresses/' do
    let(:params) do
      {
        country: 'UA',
        address: 'Yaroslaviv Val 15',
        city: 'Kiev',
        postcode: '101010',
        upload: [
          image
        ]
      }
    end

    let(:last_document) { Document.last }

    it 'saves 10 address documents successfully' do
      10.times do
        post '/api/v2/resource/addresses', headers: auth_header,
                                           params: {
                                             country: 'UA',
                                             address: 'Yaroslaviv Val 15',
                                             city: 'Kiev',
                                             postcode: '101010',
                                             upload: [fixture_file_upload('/files/documents_test.jpg', 'image/jpg')]
                                           }
      end

      expect(response.status).to eq(201)
    end

    it 'uploads 2 files at once' do
      post '/api/v2/resource/addresses', headers: auth_header,
                                         params: {
                                           country: 'UA',
                                           address: 'Yaroslaviv Val 15',
                                           city: 'Kiev',
                                           postcode: '101010',
                                           upload: [
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                           ]
                                         }
      expect(response.status).to eq(201)
      expect(test_user.documents.length).to eq(2)
    end

    it 'uploads 3 files at once' do
      post '/api/v2/resource/addresses', headers: auth_header,
                                         params: {
                                           country: 'UA',
                                           address: 'Yaroslaviv Val 15',
                                           city: 'Kiev',
                                           postcode: '101010',
                                           upload: [
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                          ]
                                         }
      expect(response.status).to eq(201)
      expect(test_user.documents.length).to eq(3)
    end

    it 'Checks if params are ok and returns success' do
      post '/api/v2/resource/addresses', headers: auth_header, params: params
      expect(response.status).to eq(201)
    end

    it 'Creates a pending address label' do
      expect(test_user.labels.find_by(key: :address)).to eq(nil)
      post '/api/v2/resource/addresses', headers: auth_header, params: params
      expect(response.status).to eq(201)
      expect(test_user.labels.find_by(key: :address)).not_to eq(nil)
      expect(test_user.labels.find_by(key: :address).value).to eq('pending')
    end

    it 'Update rejected or verified label to pending documents label on new doc' do
      expect(test_user.labels.find_by(key: :address)).to eq(nil)
      test_user.labels.create(key: :address, value: 'verified')
      test_user.reload

      post '/api/v2/resource/addresses', headers: auth_header, params: params
      expect(response.status).to eq(201)
      expect(test_user.labels.find_by(key: :address)).not_to eq(nil)
      expect(test_user.labels.find_by(key: :address).value).to eq('pending')
    end

    it 'triggers KYCService' do
      expect(KycService).to receive(:address_step)
      post '/api/v2/resource/addresses', headers: auth_header, params: params
      expect(response.status).to eq(201)
    end
  end

  context 'event API behavior' do
    let!(:url) { '/api/v2/resource/addresses' }
    let(:request_params) do
      {
        country: 'UA',
        address: 'Yaroslaviv Val 15',
        city: 'Kiev',
        postcode: '101010',
        upload: [
          image
        ]
      }
    end

    before do
      allow(EventAPI).to receive(:notify)
    end

    it 'receive model.document.created notify' do
      expect(EventAPI).to receive(:notify).ordered.with('model.user.created', hash_including(:record))
      expect(EventAPI).to receive(:notify).ordered.with('model.document.created', hash_including(:record))

      post url, headers: auth_header, params: request_params
    end
  end
end
