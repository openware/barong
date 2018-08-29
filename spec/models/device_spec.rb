# frozen_string_literal: true

RSpec.describe Device, type: :model do
  describe '#set_expire_time' do
    it 'set expire_at when result is success and otp is provided' do
      travel_to Time.now do
        device = create(:device, otp: 'provided', result: 'success')
        expect(device.expire_at).to eq 30.days.from_now
      end
    end

    it 'does not set expire_at' do
      travel_to Time.now do
        device = create(:device, otp: 'provided', result: 'error')
        expect(device.expire_at).to be_nil

        device = create(:device, otp: 'na', result: 'success')
        expect(device.expire_at).to be_nil
      end
    end
  end

  describe '#set_otp' do
    let(:otp_enabled) { false }
    let!(:account) { create :account, otp_enabled: otp_enabled }
    let!(:device) { create(:device, account: account, otp: otp) }
    subject { device.otp }

    context 'when otp is false' do
      let(:otp) { false }

      context 'when otp enabled' do
        let(:otp_enabled) { true }
        it { is_expected.to eq 'enabled' }
      end

      context 'when otp disabled' do
        let(:otp_enabled) { false }
        it { is_expected.to eq 'na' }
      end
    end

    context 'when otp is true' do
      let(:otp) { true }
      it { is_expected.to eq 'provided' }
    end

    context 'when otp is string' do
      let(:otp) { 'value' }
      it { is_expected.to eq 'value' }
    end
  end

  describe 'assign_uuid' do
    it 'assigns uuid when it is empty' do
      device = build(:device)
      expect { device.valid? }.to change { device.uuid }
    end

    it 'does not change uuid when it is present' do
      device = build(:device, uuid: 'UUID')
      expect { device.valid? }.to_not change { device.uuid }
    end
  end
end
