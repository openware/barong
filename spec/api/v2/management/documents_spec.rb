# frozen_string_literal: true

require 'rails_helper'

describe API::V2::Management::Documents, type: :request do
  before do
    defaults_for_management_api_v2_security_configuration!
    management_api_v2_security_configuration.merge! \
      scopes: {
        write_documents: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      }
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:user) { create(:user, :with_profile) }

  describe 'Show user info' do
    let(:data) do
      {
        scope: :write_documents
      }
    end
    let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }
    let(:signers) { %i[alex jeff] }
    let(:params) do
      {
        doc_type: 'Passport',
        doc_expire: '2020-01-22',
        doc_number: 'AA1234BB',
        upload: [
          image
        ]
      }
    end
    let!(:optional_params) do
      {
        metadata: {
          country: Faker::Address.country
        }
      }
    end
    let(:do_request) do
      post_json '/api/v2/management/documents',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    let(:params) do {
        uid: user.uid,
        doc_type: 'Passport',
        filename: 'documents_test',
        file_ext: '.jpg',
        doc_expire: '2020-01-22',
        doc_number: 'AA1234BB',
        upload: Base64.strict_encode64(File.open('spec/fixtures/files/documents_test.jpg').read)
      }
    end

    it 'push documents to user' do
      post_json '/api/v2/management/documents', multisig_jwt_management_api_v2({ data: params }, *signers)

      expect(response.status).to eq 201
      expect(user.documents.length).to eq(1)
    end

    it 'push documents to user twice' do
      params = {
        uid: user.uid,
        doc_type: 'Passport',
        filename: 'documents_test',
        file_ext: '.jpg',
        doc_expire: '2020-01-22',
        doc_number: 'AA1234BB',
        upload: Base64.strict_encode64(File.open('spec/fixtures/files/documents_test.jpg').read)
      }
      post_json '/api/v2/management/documents', multisig_jwt_management_api_v2({ data: params }, *signers)

      expect(response.status).to eq 201
      expect(user.documents.length).to eq(1)

      post_json '/api/v2/management/documents', multisig_jwt_management_api_v2({ data: params }, *signers)
      expect(response.status).to eq 201
      expect(user.documents.length).to eq(1)
    end
  end
end
