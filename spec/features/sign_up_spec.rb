describe 'Sign up' do
  it 'allows to sign up with email, password and password confirmation' do
    visit index_path
    click_on 'Sign up'
    fill_in 'Email', with: 'account@accounts.peatio.tech'
    fill_in 'Password', with: 'B@rong2018'
    fill_in 'Password confirmation', with: 'B@rong2018'
    click_on 'Submit'
    expect(page).to have_content(/follow the link to activate your account/)
  end
end
