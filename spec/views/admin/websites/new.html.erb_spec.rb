# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/websites/new', type: :view do
  before(:each) do
    assign(:website, Website.new(
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

  it 'renders new admin_website form' do
    render

    assert_select 'form[action=?][method=?]', admin_websites_path, 'post' do
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
