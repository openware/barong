require 'spec_helper'

RSpec.describe "documents/show", type: :view do
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

    @document = assign(:document, Document.create!(
        :profile => profile,
        :upload => File.open('app/assets/images/background.jpg'),
        :doc_type => "MyString",
        :doc_number => "MyString",
        :doc_expire => "01-01-2020"
    ))
  end

  it "renders attributes in <p>" do
    skip
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Doc Type/)
    expect(rendered).to match(/Doc Number/)
  end
end
