require 'spec_helper'

RSpec.describe "profiles/edit", type: :view do
  before(:each) do
    @profile = assign(:profile, Profile.create!(
      :account => nil,
      :first_name => "MyString",
      :last_name => "MyString",
      :address => "MyString",
      :postcode => "MyString",
      :city => "MyString",
      :country => "MyString"
    ))
  end

  it "renders the edit profile form" do
    render

    assert_select "form[action=?][method=?]", profile_path(@profile), "post" do

      assert_select "input[name=?]", "profile[account_id]"

      assert_select "input[name=?]", "profile[first_name]"

      assert_select "input[name=?]", "profile[last_name]"

      assert_select "input[name=?]", "profile[address]"

      assert_select "input[name=?]", "profile[postcode]"

      assert_select "input[name=?]", "profile[city]"

      assert_select "input[name=?]", "profile[country]"
    end
  end
end
