# frozen_string_literal: true

RSpec.describe Activity, type: :model do
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:activity) do
    create :activity, topic: 'session',
                      action: 'login',
                      result: 'succeed',
                      user_agent: 'Magic Pony Browser'
  end

  context 'General' do
    it { should belong_to(:user) }
    it {
      expect {
        activity.update_attribute(:topic, 'otp')
      }.to raise_error(ActiveRecord::ActiveRecordError, 'Activity is marked as readonly')
    }
  end

  describe 'Validations' do
    context 'Correct fields values' do
      it { should allow_value('session').for(:topic) }
      it { should allow_value('otp').for(:topic) }
      it { should allow_value('password').for(:topic) }
      it { should allow_value('succeed').for(:result) }
      it { should allow_value('failed').for(:result) }
      it { expect(activity.browser.ua).to eq 'Magic Pony Browser'}
    end

    context 'Banned actions and values' do
      it { should_not allow_value('passed').for(:result) }
      it { should_not allow_value('').for(:user_ip) }
      it { expect(activity.browser.known?).to eq false }
      it { expect(JSON.parse(activity.data)['note']).to eq 'Detected suspicious browser' }
    end
  end

  describe 'Browser functionality' do
    let(:valid_user_agent){'Android SDK 1.5r3: Mozilla/5.0 (Linux; U; Android 1.5; de-; sdk Build/CUPCAKE)
          AppleWebkit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'}
    let!(:activity) do
      create :activity, topic: 'session',
                        action: 'login',
                        result: 'succeed',
                        user_agent: valid_user_agent
    end

    context 'Detects browser information' do
      it { expect(activity.browser.name).to eq 'Safari' }
      it { expect(activity.browser.platform.android?).to eq true }
      it { expect(activity.browser.webkit?).to eq true }
      it { expect(activity.browser.full_version).to eq '3.1.2' }
      it { expect(activity.browser.version).to eq '3' }
    end
  end

end
