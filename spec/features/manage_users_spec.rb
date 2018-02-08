# frozen_string_literal: true

describe 'Admin can' do
  let(:member) { create :account }
  let(:account) { create :account }

  it 'edit roles' do
    account.update(role: :admin)
    visit index_path
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_accounts_path
    expect(page).to have_content("#{account.email}")

    click_link 'Edit'
    select 'admin', from: 'account_role'
    click_on 'Submit'
    expect(page).not_to have_content("member")
  end

  it 'delete accounts' do
    account.update(role: :admin)
    visit index_path
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_accounts_path

    click_link 'Delete'
    within('div.modal') do
      click_button 'Confirm'
    end

    visit admin_accounts_path
    expect(page).not_to have_content("#{member.email}")
  end

end
