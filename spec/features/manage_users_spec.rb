# frozen_string_literal: true

describe 'Admin can' do
  let!(:admin_account) { create :account, role: 'admin' }
  let!(:member) { create :account }

  before(:example) do
    sign_in admin_account
    visit admin_accounts_path
  end

  it 'renders correctly' do
    within(find('tbody').all('tr')[0]) do
      expect(page).to have_content(admin_account.email.to_s)
      expect(page).to have_content('admin')
      expect(page).not_to have_content('Edit')
      expect(page).not_to have_content('Delete')
    end

    within(find('tbody').all('tr')[1]) do
      expect(page).to have_content(member.email.to_s)
      expect(page).to have_content('member')
      expect(page).to have_content('Edit')
      expect(page).to have_content('Delete')
    end
  end

  it 'edit roles' do
    within(find('tbody').all('tr')[1]) do
      expect(page).to have_content('member')
      click_link 'Edit'
    end

    select 'admin', from: 'account_role'
    click_on 'Submit'
    expect(page).not_to have_content('member')
  end

  it 'delete accounts' do
    within(find('tbody').all('tr')[1]) do
      expect(page).to have_content('member')
      click_link 'Delete'
    end

    within('div.modal') do
      click_button 'Confirm'
    end

    visit admin_accounts_path
    expect(page).not_to have_content(member.email.to_s)
  end
end
