require 'rails_helper'

RSpec.describe "admin/websites/edit", type: :view do
  before(:each) do
    @admin_website = assign(:admin_website, Website.create!(
      :domain => "MyString",
      :title => "MyString",
      :logo => "MyString",
      :stylesheet => "MyString",
      :header => "MyText",
      :footer => "MyText",
      :redirect_url => "MyString",
      :state => "MyString"
    ))
  end

  it "renders the edit admin_website form" do
    render

    assert_select "form[action=?][method=?]", admin_website_path(@admin_website), "post" do

      assert_select "input[name=?]", "admin_website[domain]"

      assert_select "input[name=?]", "admin_website[title]"

      assert_select "input[name=?]", "admin_website[logo]"

      assert_select "input[name=?]", "admin_website[stylesheet]"

      assert_select "textarea[name=?]", "admin_website[header]"

      assert_select "textarea[name=?]", "admin_website[footer]"

      assert_select "input[name=?]", "admin_website[redirect_url]"

      assert_select "input[name=?]", "admin_website[state]"
    end
  end
end
