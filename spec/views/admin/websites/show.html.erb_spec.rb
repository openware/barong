# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/websites/show', type: :view do
  before(:each) do
    @website = assign(:admin_website, Website.create!(
                                        domain: 'Domain',
                                        title: 'Title',
                                        logo: 'Logo',
                                        stylesheet: 'Stylesheet',
                                        header: 'MyText',
                                        footer: 'MyText',
                                        redirect_url: 'Redirect Url',
                                        state: 'State'
                                      ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Domain/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Logo/)
    expect(rendered).to match(/Stylesheet/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Redirect Url/)
    expect(rendered).to match(/State/)
  end
end
