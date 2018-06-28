# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'profiles/new', type: :view do
  before(:each) do
    assign(:profile, Profile.new(
                       account: nil,
                       first_name: 'MyString',
                       last_name: 'MyString',
                       address: 'MyString',
                       postcode: 'MyString',
                       city: 'MyString',
                       country: 'MyString',
                       dob: '01-01-2001'
                     ))
  end

  it 'renders new profile form' do
    render

    assert_select 'form[action=?][method=?]', profiles_path, 'post' do
      assert_select 'input[name=?]', 'profile[first_name]'

      assert_select 'input[name=?]', 'profile[last_name]'

      assert_select 'input[name=?]', 'profile[dob]'

      assert_select 'select[name=?]', 'profile[country]'
    end
  end
end
