require 'spec_helper'

RSpec.describe Profile, type: :model do

  ## Test of relationships
  it { should have_many(:documents).dependent(:destroy) }
  it { should belong_to(:account) }

  context 'Profile with 2 documents' do
    it do
      account = Account.create!(email: 'test@gmail.com', password: 'Test123123')
      profile = Profile.create!(account: account)
      document1 = profile.documents.create!(doc_expire: Date.today)
      document2 = profile.documents.create!(doc_expire: Date.today + 1.day)
      expect(profile.reload.documents).to eq([document1, document2])
    end
  end

end