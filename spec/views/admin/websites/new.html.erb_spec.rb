require 'rails_helper'

RSpec.describe "admin/websites/new", type: :view do
  before(:each) do
    assign(:admin_website, Website.new(
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

  it "renders new admin_website form" do
    render

    assert_select "form[action=?][method=?]", websites_path, "post" do

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
