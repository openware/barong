require 'spec_helper'

RSpec.describe "profiles/edit", type: :view do
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

  it "renders the edit profile form" do
    render

    assert_select "form[action=?][method=?]", profile_path(@profile), "post" do

      assert_select "input[name=?]", "profile[first_name]"

      assert_select "input[name=?]", "profile[last_name]"

      assert_select "input[name=?]", "profile[dob]"

      assert_select "select[name=?]", "profile[country]"
    end
  end
end
