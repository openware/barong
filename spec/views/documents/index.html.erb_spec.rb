require 'spec_helper'

RSpec.describe "documents/index", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    profile = assign(:profile, Profile.create!(
         :account => account,
         :first_name => "MyString",
         :last_name => "MyString",
         :address => "MyString",
         :postcode => "MyString",
         :city => "MyString",
         :country => "MyString",
         :dob => "01-01-2001"))

    assign(:documents, [
      Document.create!(
        :profile => profile,
        :upload => File.open('app/assets/images/background.jpg'),
        :doc_type => "Doc Type",
        :doc_number => "Doc Number",
        :doc_expire => "01-01-2020"
      ),
      Document.create!(
        :profile => profile,
        :upload => File.open('app/assets/images/background.jpg'),
        :doc_type => "Doc Type",
        :doc_number => "Doc Number",
        :doc_expire => "01-02-2020"
      )
    ])
  end

  it "renders a list of documents" do
    skip
    render
    assert_select "tr>td", :text => nil.to_s, :count => 4
    assert_select "tr>td", :text => "Doc Type".to_s, :count => 2
    assert_select "tr>td", :text => "Doc Number".to_s, :count => 2
  end
end
