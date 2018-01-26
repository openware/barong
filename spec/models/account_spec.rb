require 'spec_helper'

RSpec.describe Account, type: :model do

  ## Test of validations
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  ## Test of relationships
  it { should have_one(:profile).dependent(:destroy) }

  context 'Profile with 2 or more documents' do
    it do
      account = Account.create!(email: 'test@mail.com', password: '123123')
      expect(Account.count).to eq 1
      profile = Profile.create!(account: account)
      expect(Profile.count).to eq 1
      document1 = profile.documents.create!(doc_expire: Date.today + 3.weeks)
      document2 = profile.documents.create!(doc_expire: Date.today + 2.years)
      expect(profile.reload.documents).to eq([document1, document2])

    end

    after(:all) { Account.destroy_all }
  end

end