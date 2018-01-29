# frozen_string_literal: true

describe 'Phone verification' do
  let!(:account) { create :account }

  it 'can access page' do
    account.update(level: 1)
    visit index_path
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit new_phone_path
    expect(page).to have_content('Add mobile phone')
  end

  it 'verifies phone number' do
    account.update(level: 1)
    visit index_path
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit new_phone_path
    fill_in 'number', with: 'qwerty'
    click_on 'Get verification code'
    expect(page).to have_content('invalid')
  end

  it 'verifies phone number' do
    account.update(level: 1)
    visit index_path
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit new_phone_path
    fill_in 'number', with: '+380955555555'
    click_on 'Get verification code'
    expect(page).not_to have_content('invalid')
  end

  it 'creates phone' do
    account.update(level: 1)
    visit index_path
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit new_phone_path
    fill_in 'number', with: '+380955555555'
    click_on 'Get verification code'
    sleep 1 #FIXME we need to wait for html event
    fill_in 'code', with: FakeSMS.messages.last.body.split.last
    click_on 'Next'
    expect(page).to have_content('Complete your profile')
  end
end
