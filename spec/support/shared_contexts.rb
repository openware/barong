# frozen_string_literal: true

shared_context 'jwt authentication' do
  let!(:current_account) { create(:account) }
  let(:access_token) do
    create_jwt_token(current_account)
  end

  let(:auth_header) { { 'Authorization' => "Bearer #{access_token}" } }
end
