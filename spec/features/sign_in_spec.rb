# frozen_string_literal: true

describe 'Sign in' do
  let!(:account) { create :account }

  it 'allows to sign in with email and password' do
    visit index_path
    click_on 'Sign in'
    fill_in 'Email', with: account.email
    fill_in 'Password', with: account.password
    click_on 'Submit'
    expect(page).to have_content("Signed in as #{account.email}.")
  end
end
