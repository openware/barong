require 'spec_helper'

RSpec.describe "profiles/show", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    @profile = assign(:profile, Profile.create!(
      :account => account,
      :first_name => "MyString",
      :last_name => "MyString",
      :address => "MyString",
      :postcode => "MyString",
      :city => "MyString",
      :country => "MyString",
      :dob => "01-01-2001"
    ))
  end

  it "renders attributes in <p>" do
    skip
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Postcode/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/Country/)
  end
end
