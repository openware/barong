require 'rails_helper'

RSpec.describe "admin/websites/index", type: :view do
  before(:each) do
    assign(:websites, [
      Website.create!(
        :domain => "Domain",
        :title => "Title",
        :logo => "Logo",
        :stylesheet => "Stylesheet",
        :header => "MyText",
        :footer => "MyText",
        :redirect_url => "Redirect Url",
        :state => "State"
      ),
      Website.create!(
        :domain => "Domain",
        :title => "Title",
        :logo => "Logo",
        :stylesheet => "Stylesheet",
        :header => "MyText",
        :footer => "MyText",
        :redirect_url => "Redirect Url",
        :state => "State"
      )
    ])
  end

  it "renders a list of admin/websites" do
    render
    assert_select "tr>td", :text => "Domain".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Logo".to_s, :count => 2
    assert_select "tr>td", :text => "Stylesheet".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Redirect Url".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
  end
end
