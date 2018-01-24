require 'spec_helper'

describe "admin/websites/index", type: :feature do
  let!(:website) { create :website, id: 1 }
  let!(:another_website) { create :website, id: 2 }
  let!(:account) { create :account }

  it "renders a list of admin/websites" do
    account.update(role: :admin)
    visit index_path
    click_on 'Sign in'
    fill_in 'account_email', with: account.email
    fill_in 'account_password', with: account.password
    click_on 'Submit'
    visit admin_websites_path
    expect(page).to have_content("#{website.domain}")
                    have_content("#{website.title}")
                    have_content("#{another_website.domain}")
                    have_content("#{another_website.title}")
  end
end
