require 'spec_helper'

RSpec.describe "profiles/show", type: :view do
  before(:each) do
    @profile = assign(:profile, Profile.create!(
      :account => nil,
      :first_name => "First Name",
      :last_name => "Last Name",
      :address => "Address",
      :postcode => "Postcode",
      :city => "City",
      :country => "Country"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Postcode/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/Country/)
  end
end
