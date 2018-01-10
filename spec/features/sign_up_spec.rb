# frozen_string_literal: true

describe 'Sign up' do
  it 'allows to sign up with email, password and password confirmation' do
    visit index_path
    click_on 'Sign up'
    fill_in 'account_email', with: 'account@accounts.peatio.tech'
    fill_in 'account_password', with: 'B@rong2018'
    fill_in 'account_password_confirmation', with: 'B@rong2018'
    click_on 'Submit'
    expect(page).to have_content(/follow the link to activate your account/)
  end
end
