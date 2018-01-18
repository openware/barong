# frozen_string_literal: true

describe 'Admin sign in' do
  let(:account) { create :account }

  it 'allows to sign in as admin' do
    account.update(role: :admin)
    visit index_path
    click_on 'Sign in'
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_dashboard_path
    expect(page).to have_content("Welcome, #{account.email}!")
  end

end
