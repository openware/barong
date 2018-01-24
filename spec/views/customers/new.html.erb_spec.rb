require 'spec_helper'

RSpec.describe "customers/new", type: :view do
  before(:each) do
    assign(:customer, Customer.new(
      :first_name => "MyString",
      :last_name => "MyString",
      :address => "MyString",
      :postcode => "MyString",
      :city => "MyString",
      :country => "MyString"
    ))
  end

  it "renders new customer form" do
    render

    assert_select "form[action=?][method=?]", customers_path, "post" do

      assert_select "input[name=?]", "customer[first_name]"

      assert_select "input[name=?]", "customer[last_name]"

      assert_select "input[name=?]", "customer[address]"

      assert_select "input[name=?]", "customer[postcode]"

      assert_select "input[name=?]", "customer[city]"

      assert_select "input[name=?]", "customer[country]"
    end
  end
end
