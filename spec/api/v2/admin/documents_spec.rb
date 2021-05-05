# frozen_string_literal: true

describe 'Api::V2::Admin::Documents' do
  include_context 'bearer authentication'

  let!(:create_superadmin_permission) do
    create :permission,
           role: 'superadmin'
  end

  let!(:create_support_permission) do
    create :permission,
           role: 'support'
  end

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  describe 'GET /api/v2/admin/documents/:id' do
    let(:user_with_document) { create(:user, :with_document, role: 'member') }
    let(:document) { user_with_document.documents.last}

    context 'superadmin user' do
      let(:test_user) { create(:user, email: 'example@gmail.com', role: 'superadmin') }

      it 'returns the URL to the document on storage' do
        get "/api/v2/admin/documents/#{document.id}", headers: auth_header

        expect(response.status).to eq(302)
        expect(JSON.parse(response.body)).to eq("This resource has been moved temporarily to #{document.upload_url}.")
      end

      it 'returns 404' do
        get "/api/v2/admin/documents/0", headers: auth_header

        expect(response.status).to eq(404)
        result = JSON.parse(response.body)
        expect(result['errors']).to eq(['admin.document.doesnt_exist'])
      end
    end

    context 'support user' do
      let(:test_user) { create(:user, email: 'example@gmail.com', role: 'support') }

      it 'returns the URL to the document on storage' do
        get "/api/v2/admin/documents/#{document.id}", headers: auth_header

        expect(response.status).to eq(401)
        result = JSON.parse(response.body)
        expect(result['errors']).to eq(['admin.ability.not_permitted'])
      end
    end
  end
end
