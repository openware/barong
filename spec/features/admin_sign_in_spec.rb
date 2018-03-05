# frozen_string_literal: true

describe 'Admin sign in' do
  let(:account) { create :account }

  it 'allows to sign in as admin' do
    account.update(role: :admin)
    sign_in account
    visit admin_accounts_path
    expect(page).to have_text(/Applications/)
  end
end
