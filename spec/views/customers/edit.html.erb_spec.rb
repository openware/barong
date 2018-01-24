require 'spec_helper'

RSpec.describe "customers/edit", type: :view do
  before(:each) do
    @customer = assign(:customer, Customer.create!(
      :first_name => "MyString",
      :last_name => "MyString",
      :address => "MyString",
      :postcode => "MyString",
      :city => "MyString",
      :country => "MyString"
    ))
  end

  it "renders the edit customer form" do
    render

    assert_select "form[action=?][method=?]", customer_path(@customer), "post" do

      assert_select "input[name=?]", "customer[first_name]"

      assert_select "input[name=?]", "customer[last_name]"

      assert_select "input[name=?]", "customer[address]"

      assert_select "input[name=?]", "customer[postcode]"

      assert_select "input[name=?]", "customer[city]"

      assert_select "input[name=?]", "customer[country]"
    end
  end
end
