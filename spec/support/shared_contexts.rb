shared_context 'doorkeeper authentication' do
  let!(:current_account) { create(:account) }
  let!(:current_application) { Doorkeeper::Application.create!(name: 'test',
                                                       redirect_uri: 'https://test.test')  }
  let(:access_token) do
    Doorkeeper::AccessToken.create!(application_id: current_application.id,
                                    resource_owner_id: current_account.id,
                                    scopes: 'test')
  end

  let(:auth_header) { { 'Authorization' => "Bearer #{access_token.token}" } }
end
