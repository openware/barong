# frozen_string_literal: true

describe EncryptionService do
  context 'current_salt' do
    it { expect(EncryptionService.current_salt).to eq Time.now.strftime('%Y%W') }

    it do
      allow(Time).to receive(:now).and_return(1.week.ago)
      expect(EncryptionService.current_salt).to eq Time.now.strftime('%Y%W')
    end
  end

  context 'pack' do
    it { expect(EncryptionService.pack('salt', 'value')).to eq 'salt.value' }
    it { expect(EncryptionService.pack('salt', nil)).to eq 'salt.' }
    it { expect(EncryptionService.pack('salt', '')).to eq 'salt.' }
  end

  context 'unpack' do
    it { expect(EncryptionService.unpack('salt.value')).to eq ['salt', 'value'] }
    it { expect(EncryptionService.unpack('salt.value.value')).to eq ['salt', 'value.value'] }
    it { expect(EncryptionService.unpack(' salt.value')).to eq ['salt', 'value'] }
    it { expect(EncryptionService.unpack(' salt_underscore.value')).to eq ['salt_underscore', 'value'] }
    it { expect(EncryptionService.unpack('salt.')).to eq ['salt', ''] }
    it { expect { EncryptionService.unpack('salt') }.to raise_error('Invalid encrypted value: salt') }
  end

  context 'encrypt' do
    let(:time) { Time.now.strftime('%Y%W') }
    it { expect(EncryptionService.encrypt('value')).to match(/#{time}/) }
  end

  context 'decrypt' do
    let(:encrypted_key) { EncryptionService.encrypt('value') }
    it { expect(EncryptionService.decrypt(encrypted_key)).to eq 'value' }
  end
end
