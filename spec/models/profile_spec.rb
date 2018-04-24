# frozen_string_literal: true

ENV['SENDER_EMAIL'] = 'test@barong.test'

RSpec.describe Profile, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }
  let(:level_label) do
    Label.find_by(account_id: profile.account.id, key: 'account_level')
  end

  describe 'state update' do
    let(:profile)  { create :profile }
    let(:mailer_deliveries) { ActionMailer::Base.deliveries }

    it 'changes account level' do
      profile.update(state: 'approved')
      expect(profile.account.level).to eq(3)

      profile.update(state: 'rejected')
      expect(profile.account.level).to eq(2)
    end

    after(:each) do
      mailer_deliveries.clear
    end

    it 'sends notification emails' do
      profile.update(state: 'approved')
      expect(profile.account.level).to eq(3)
      expect(mailer_deliveries.last.to).to eq([profile.account.email])
      expect(mailer_deliveries.last.subject).to eq('Your identity was approved')
      expect(mailer_deliveries.last.from).to eq([ENV['SENDER_EMAIL']])
      expect(level_label.value).to eq 'documents_checked'

      profile.update(state: 'rejected')
      expect(profile.account.level).to eq(2)
      expect(mailer_deliveries.last.to).to eq([profile.account.email])
      expect(mailer_deliveries.last.subject).to eq('Your identity was rejected')
      expect(level_label.reload.value).to eq 'profile_filled'
    end
  end

  describe '#set_account_level' do
    let!(:profile) { create :profile }

    it 'updates account level' do
      expect(level_label.value).to eq 'profile_filled'
    end
  end
end
