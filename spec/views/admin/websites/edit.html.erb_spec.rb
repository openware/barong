# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/websites/edit', type: :view do
  before(:each) do
    @website = assign(:admin_website, Website.create!(
                                        domain: 'MyString',
                                        title: 'MyString',
                                        logo: 'MyString',
                                        stylesheet: 'MyString',
                                        header: 'MyText',
                                        footer: 'MyText',
                                        redirect_url: 'MyString',
                                        state: 'MyString'
                                      ))
  end

  it 'renders the edit admin_website form' do
    render

    assert_select 'form[action=?][method=?]', admin_website_path(@website.id), 'post' do
      assert_select 'input[name=?]', 'website[domain]'

      assert_select 'input[name=?]', 'website[title]'

      assert_select 'input[name=?]', 'website[logo]'

      assert_select 'input[name=?]', 'website[stylesheet]'

      assert_select 'textarea[name=?]', 'website[header]'

      assert_select 'textarea[name=?]', 'website[footer]'

      assert_select 'input[name=?]', 'website[redirect_url]'

      assert_select 'input[name=?]', 'website[state]'
    end
  end
end
