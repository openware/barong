require 'spec_helper'

RSpec.describe "documents/edit", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    profile = assign(:profile, Profile.create!(account: account))

    @document = assign(:document, Document.create!(
      :profile => profile,
      :upload => "MyString",
      :doc_type => "MyString",
      :doc_number => "MyString"
    ))
  end

  it "renders the edit document form" do
    render

    assert_select "form[action=?][method=?]", document_path(@document), "post" do

      assert_select "select[name=?]", "document[doc_type]"

      assert_select "input[name=?]", "document[doc_number]"

      assert_select "select[name=?]", "document[doc_expire(1i)]"

      assert_select "select[name=?]", "document[doc_expire(2i)]"

      assert_select "select[name=?]", "document[doc_expire(3i)]"
    end
  end
end
