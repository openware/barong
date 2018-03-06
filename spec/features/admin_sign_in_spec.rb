# frozen_string_literal: true

describe 'Admin sign in' do
  let!(:admin) { create :admin }

  before(:example) do
    sign_in admin
    visit admin_accounts_path
  end

  it 'allows to sign in as admin' do
    expect(page).to have_content(/Applications/)
  end
end
