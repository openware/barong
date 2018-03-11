require 'spec_helper'

RSpec.describe Profile, type: :model do

  ## Test of relationships
  it { should have_many(:documents).dependent(:destroy) }
  it { should belong_to(:account) }

  context 'Profile with 2 documents' do
    it do
      account = Account.create!(email: 'test@gmail.com', password: 'Test123123')
      profile = Profile.create!(
         :account => account,
         :first_name => "MyString",
         :last_name => "MyString",
         :address => "MyString",
         :postcode => "MyString",
         :city => "MyString",
         :country => "MyString",
         :dob => "01-01-2001")
      document1 = profile.documents.create!(:upload => File.open('app/assets/images/background.png'),
        :doc_type => "MyString",
        :doc_number => "MyString",
        :doc_expire => "01-01-2020")
      document2 = profile.documents.create!(:upload => File.open('app/assets/images/background.png'),
        :doc_type => "MyString",
        :doc_number => "MyString",
        :doc_expire => "01-02-2020")
      expect(profile.reload.documents).to eq([document1, document2])
    end
  end

end