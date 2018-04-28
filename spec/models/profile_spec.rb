# frozen_string_literal: true

ENV['SENDER_EMAIL'] = 'test@barong.test'

RSpec.describe Profile, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }

  describe 'state update' do
    let(:profile)  { create :profile }
    let(:mailer_deliveries) { ActionMailer::Base.deliveries }

    describe 'changes account level' do
      it 'changes account level from 3 to 4' do
        set_level(profile.account, 3)
        profile.update(state: 'approved')
        expect(profile.account.level).to eq(4)
      end

      it 'changes account level from 4 to 3' do
        set_level(profile.account, 4)
        profile.update(state: 'rejected')
        expect(profile.account.level).to eq(3)
      end
    end

    after(:each) do
      mailer_deliveries.clear
    end

    it 'sends notification emails' do
      set_level(profile.account, 3)
      profile.update(state: 'approved')
      expect(profile.account.level).to eq(4)
      expect(mailer_deliveries.last.to).to eq([profile.account.email])
      expect(mailer_deliveries.last.subject).to eq('Your identity was approved')
      expect(mailer_deliveries.last.from).to eq([ENV['SENDER_EMAIL']])

      set_level(profile.account, 4)
      profile.update(state: 'rejected')
      expect(profile.account.level).to eq(3)
      expect(mailer_deliveries.last.to).to eq([profile.account.email])
      expect(mailer_deliveries.last.subject).to eq('Your identity was rejected')
    end
  end
end
