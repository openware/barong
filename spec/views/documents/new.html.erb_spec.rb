require 'spec_helper'

RSpec.describe "documents/new", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    profile = assign(:profile, Profile.create!(account: account))

    assign(:document, Document.new(
        :profile => profile,
        :upload => File.open('app/assets/images/logo-black.png'),
        :doc_type => "MyString",
        :doc_number => "MyString"
    ))
  end

  it "renders new document form" do
    skip
    render

    assert_select "form[action=?][method=?]", documents_path, "post" do

      assert_select "select[name=?]", "document[doc_type]"

      assert_select "input[name=?]", "document[doc_number]"
    end
  end
end
