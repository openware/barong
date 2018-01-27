require 'spec_helper'

RSpec.describe "documents/index", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    profile = assign(:profile, Profile.create!(account: account))

    assign(:documents, [
      Document.create!(
        :profile => profile,
        :upload => File.open('app/assets/images/logo-black.png'),
        :doc_type => "Doc Type",
        :doc_number => "Doc Number"
      ),
      Document.create!(
        :profile => profile,
        :upload => File.open('app/assets/images/logo-black.png'),
        :doc_type => "Doc Type",
        :doc_number => "Doc Number"
      )
    ])
  end

  it "renders a list of documents" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 4
    assert_select "tr>td", :text => "Doc Type".to_s, :count => 2
    assert_select "tr>td", :text => "Doc Number".to_s, :count => 2
  end
end
