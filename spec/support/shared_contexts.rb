# frozen_string_literal: true

shared_context 'doorkeeper authentication' do
  let!(:current_account) { create(:account) }
  let(:access_token) do
    create(:doorkeeper_token, resource_owner_id: current_account.id)
  end

  let(:auth_header) { { 'Authorization' => "Bearer #{access_token.token}" } }
end
