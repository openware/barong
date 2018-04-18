# frozen_string_literal: true

describe Vault::TOTP do
  let(:uid) { 'uid' }
  let(:email) { 'email' }

  describe '.server_available?' do
    subject { described_class.server_available? }

    context 'when server is available' do
      before { expect(described_class).to receive(:read_data) { ['data'] } }
      it { is_expected.to eq true }
    end

    context 'when server is not available' do
      before { expect(described_class).to receive(:read_data) { [] } }
      it { is_expected.to eq false }
    end

    context 'when exception raised' do
      before do
        expect(described_class).to receive(:read_data).and_raise(StandardError, 'vault error')
      end

      it { is_expected.to eq false }
    end
  end

  describe '.otp_secret' do
    let(:otp_url) { 'otpauth://totp/Barong:admin@barong.io?secret=code' }
    let(:otp) { double(data: { url: otp_url }) }
    it { expect(described_class.otp_secret(otp)).to eq 'code' }
  end

  describe '.safe_create' do
    it 'does not create secret when it exists' do
      expect(described_class).to receive(:exist?).with(uid) { true }
      expect(described_class).to_not receive(:create)
      described_class.safe_create(uid, email)
    end

    it 'creates secret when it does not exist' do
      expect(described_class).to receive(:exist?).with(uid) { false }
      expect(described_class).to receive(:create).with(uid, email)
      described_class.safe_create(uid, email)
    end
  end

  describe '.create' do
    let(:create_params) do
      {
        generate: true,
        issuer: 'Barong',
        account_name: 'email',
        qr_size: 300
      }
    end

    it 'creates secret' do
      expect(described_class).to receive(:write_data)
        .with('totp/keys/uid', create_params)
      described_class.create(uid, email)
    end
  end

  describe '.exist?' do
    it 'creates secret' do
      expect(described_class).to receive(:read_data)
        .with('totp/keys/uid') { ['data'] }
      described_class.exist?(uid)
    end
  end

  describe '.validate?' do
    before do
      allow(described_class).to receive(:write_data) { double(data: data) }
    end
    let(:data) { { valid: true } }

    subject { described_class.validate?(uid, 'code') }

    context 'when not exist' do
      before { expect(described_class).to receive(:exist?) { false } }
      it { is_expected.to eq false }
    end

    context 'when valid' do
      before { expect(described_class).to receive(:exist?) { true } }
      it { is_expected.to eq true }
    end

    context 'when invalid' do
      before { expect(described_class).to receive(:exist?) { true } }
      let(:data) { { valid: false } }
      it { is_expected.to eq false }
    end
  end

  describe '.delete' do
    before { expect(described_class).to receive(:delete_data) }
    it { expect(described_class.delete(uid)) }
  end

  describe 'private methods' do
    let(:fake_vault) { double(read: 'read', write: 'writed', delete: 'deleted') }
    before { stub_const('Vault', double(logical: fake_vault)) }

    it 'read_data reads from vault storage' do
      expect(described_class.send(:read_data, 'key')).to eq 'read'
    end

    it 'write_data writes to vault storage' do
      expect(described_class.send(:write_data, 'key', {})).to eq 'writed'
    end

    it 'delete_data deletes from vault storage' do
      expect(described_class.send(:delete_data, 'key')).to eq 'deleted'
    end
  end
end
