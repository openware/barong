# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Account, type: :model do
  ## Test of validations
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should have_many(:documents).dependent(:destroy) }

  ## Test of relationships
  it { should have_one(:profile).dependent(:destroy) }

  context 'Account with 2 or more documents' do
    it do
      account = Account.create!(email: 'test@mail.com', password: '123123')
      expect(Account.count).to eq 1
      document1 = account.documents.create!(upload: File.open('app/assets/images/background.jpg'),
                                            doc_type: 'MyString',
                                            doc_number: 'MyString',
                                            doc_expire: '01-01-2020')
      document2 = account.documents.create!(upload: File.open('app/assets/images/background.jpg'),
                                            doc_type: 'MyString',
                                            doc_number: 'MyString',
                                            doc_expire: '01-02-2020')
      expect(account.reload.documents).to eq([document1, document2])
    end

    after(:all) { Account.destroy_all }
  end
end
