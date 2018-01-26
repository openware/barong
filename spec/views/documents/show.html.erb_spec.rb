require 'spec_helper'

RSpec.describe "documents/show", type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@mail.com', password: 'MyString'))

    profile = assign(:profile, Profile.create!(account: account))

    @document = assign(:document, Document.create!(
      :profile => profile,
      :upload_id => "Upload",
      :upload_filename => "Upload Filename",
      :upload_content_size => "Upload Content Size",
      :upload_content_type => "Upload Content Type",
      :doc_type => "Doc Type",
      :doc_number => "Doc Number"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Upload/)
    expect(rendered).to match(/Upload Filename/)
    expect(rendered).to match(/Upload Content Size/)
    expect(rendered).to match(/Upload Content Type/)
    expect(rendered).to match(/Doc Type/)
    expect(rendered).to match(/Doc Number/)
  end
end
