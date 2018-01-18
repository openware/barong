# frozen_string_literal: true

describe 'Admin sign in' do
  let!(:member) { create :account }
  let!(:account) { create :account }

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

  it 'allows to edit roles' do
    account.update(role: :admin)
    visit index_path
    click_on 'Sign in'
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_accounts_path
    expect(page).to have_content("#{member.email}")

    page.first('.btn-info').click
    fill_in 'account_role', with: 'admin'
    click_on 'Update'
    expect(page).not_to have_content("member")
  end

  it 'allows to delete accounts' do
    account.update(role: :admin)
    visit index_path
    click_on 'Sign in'
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_accounts_path

    accept_alert do
      page.first(".btn-danger").click
    end
    visit admin_accounts_path
    expect(page).not_to have_content("#{member.email}")
  end

end
