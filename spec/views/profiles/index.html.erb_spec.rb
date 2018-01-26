require 'spec_helper'

RSpec.describe "profiles/index", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    assign(:profiles, [
      Profile.create!(
        :account => account,
        :first_name => "First Name",
        :last_name => "Last Name",
        :address => "Address",
        :postcode => "Postcode",
        :city => "City",
        :country => "Country"
      ),
      Profile.create!(
        :account => account,
        :first_name => "First Name",
        :last_name => "Last Name",
        :address => "Address",
        :postcode => "Postcode",
        :city => "City",
        :country => "Country"
      )
    ])
  end

  it "renders a list of profiles" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Postcode".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => "Country".to_s, :count => 2
  end
end
