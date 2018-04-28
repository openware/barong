# frozen_string_literal: true

describe 'Phone verification' do
  let!(:account) { create :account }

  before(:example) do
    set_level(account, 1)
    sign_in account
    visit new_phone_path
  end

  it 'can access page' do
    expect(page).to have_content('Add mobile phone')
  end

  it 'verifies phone number' do
    fill_in 'number', with: 'qwerty'
    click_on 'Send code'
    expect(page).to have_content('invalid')
  end

  it 'verifies phone number' do
    fill_in 'number', with: '+380955555555'
    click_on 'Send code'
    expect(page).not_to have_content('invalid')
  end

  it 'creates phone' do
    fill_in 'number', with: '+380955555555'
    click_on 'Send code'
    sleep 1 # FIXME: we need to wait for html event
    fill_in 'Enter code', with: FakeSMS.messages.last.body.split.last
    click_on 'CONFIRM'
    expect(page).to have_content('Verification > Fill in personal information')
  end
end
