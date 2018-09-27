# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'documents/new', type: :view do
  before(:each) do
    account = assign(:account, Account.create!(email: 'myemail@gmail.com', password: 'MyString1'))
    assign(:document, Document.new(
                        account: account,
                        upload: File.open('app/assets/images/background.jpg'),
                        doc_type: 'MyString',
                        doc_number: 'MyString',
                        doc_expire: '01-01-2020'
                      ))
  end

  it 'renders new document form' do
    render

    assert_select 'form[action=?][method=?]', documents_path, 'post' do
      assert_select 'select[name=?]', 'document[doc_type]'

      assert_select 'input[name=?]', 'document[doc_number]'
    end
  end
end
