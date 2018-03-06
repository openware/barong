# frozen_string_literal: true

describe 'Sign up' do
  let(:params) { attributes_for :account }

  it 'allows to sign up with email, password and password confirmation' do
    visit new_account_registration_path

    fill_in 'account_email', with: params[:email]
    fill_in 'account_password', with: params[:password]
    fill_in 'account_password_confirmation', with: params[:password]

    click_on 'Submit'

    expect(page).to have_content(/follow the link to activate your account/)
  end
end
