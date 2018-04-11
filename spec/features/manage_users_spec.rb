# frozen_string_literal: true

describe 'Admin can' do
  before(:example) do
    account.update(role: :admin)
    sign_in account
    visit admin_accounts_path
  end
  let(:member) { create :account }
  let(:account) { create :account }

  it 'edit roles' do
    expect(page).to have_content(account.email.to_s)
    click_link 'Edit'
    select 'admin', from: 'account_role'
    click_on 'Submit'
    expect(page).not_to have_content('member')
  end

  it 'delete accounts' do
    click_link 'Delete'
    within('div.modal') do
      click_button 'Confirm'
    end

    visit admin_accounts_path
    expect(page).not_to have_content(member.email.to_s)
  end
end
