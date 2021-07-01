# frozen_string_literal: true

require 'rails_helper'

describe API::V2::Management::Attachments, type: :request do
  before do
    defaults_for_management_api_v2_security_configuration!
    management_api_v2_security_configuration.merge! \
      scopes: {
        write_attachments: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      }
  end

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let!(:user) { create(:user, :with_profile) }

  describe 'Create attachment' do
    let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }
    let(:signers) { %i[alex jeff] }

    let(:params) do {
      uid: user.uid,
      filename: 'documents_test',
      file_ext: '.jpg',
      upload: Base64.strict_encode64(File.open('spec/fixtures/files/documents_test.jpg').read)
    }
    end

    it 'creates attachment' do
      post_json '/api/v2/management/attachments', multisig_jwt_management_api_v2({ data: params }, *signers)

      expect(response.status).to eq 201
      expect(Attachment.count).to eq(1)
    end

    it 'creates attachment without user' do
      post_json '/api/v2/management/attachments', multisig_jwt_management_api_v2({ data: params.except(:uid) }, *signers)

      expect(response.status).to eq 201
      expect(Attachment.count).to eq(1)
      expect(JSON.parse(response.body)['uid']).to eq nil
    end
  end
end
