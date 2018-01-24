require 'spec_helper'

describe "admin/websites/edit", type: :feature do
  let!(:website) { create :website }
  let!(:account) { create :account }

  it "renders the edit admin_website form" do
    account.update(role: :admin)
    visit index_path
    click_on 'Sign in'
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit edit_admin_website_path(website)
    expect(page).to have_field 'Domain'
                    have_field 'Title'
                    have_field 'Logo'
                    have_field 'Stylesheet'
                    have_field 'Header'
                    have_field 'Footer'
                    have_field 'Redirect url'
                    have_field 'State'
  end
end
