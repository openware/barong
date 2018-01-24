require 'spec_helper'

describe "admin/websites/show", type: :feature do
  let!(:account) { create :account }
  let!(:website) { create :website }

  it "renders attributes in <p>" do
    account.update(role: :admin)
    visit index_path
    click_on 'Sign in'
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_website_path(website)
    expect(page).to have_content("#{website.domain}")
                    have_content("#{website.title}")
                    have_content("#{website.logo}")
                    have_content("#{website.stylesheet}")
                    have_content("#{website.header}")
                    have_content("#{website.footer}")
                    have_content("#{website.redirect_url}")
  end
end
