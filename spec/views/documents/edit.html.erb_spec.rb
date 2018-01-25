require 'spec_helper'

RSpec.describe "documents/edit", type: :view do
  before(:each) do
    @document = assign(:document, Document.create!(
      :profile => nil,
      :upload_id => "MyString",
      :upload_filename => "MyString",
      :upload_content_size => "MyString",
      :upload_content_type => "MyString",
      :doc_type => "MyString",
      :doc_number => "MyString"
    ))
  end

  it "renders the edit document form" do
    render

    assert_select "form[action=?][method=?]", document_path(@document), "post" do

      assert_select "input[name=?]", "document[profile_id]"

      assert_select "input[name=?]", "document[upload_id]"

      assert_select "input[name=?]", "document[upload_filename]"

      assert_select "input[name=?]", "document[upload_content_size]"

      assert_select "input[name=?]", "document[upload_content_type]"

      assert_select "input[name=?]", "document[doc_type]"

      assert_select "input[name=?]", "document[doc_number]"
    end
  end
end
