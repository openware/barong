# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Admin::Attachments, type: :request do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end

  describe 'Get attachment url' do

    let!(:attachment) { create(:attachment) }

    it 'returns attachment url' do
      get "/api/v2/admin/attachments/#{attachment.id}/upload", headers: auth_header

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['url']).to eq attachment.upload.url
    end

    it 'returns 404' do
      get "/api/v2/admin/attachments/#{Attachment.last.id + 1}/upload", headers: auth_header

      expect(response.status).to eq 404
    end
  end
end
