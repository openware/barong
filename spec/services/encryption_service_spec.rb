# frozen_string_literal: true

describe EncryptionService do
  context 'current_salt' do
    before(:each) do
      EncryptionService.instance_variable_set(:@cache, {})
    end

    it { expect(EncryptionService.current_salt).to eq Time.now.strftime('%Y%W') }

    it do
      allow(Time).to receive(:now).and_return(1.week.ago)
      expect(EncryptionService.current_salt).to eq Time.now.strftime('%Y%W')
    end
  end

  context 'pack' do
    before(:each) do
      EncryptionService.instance_variable_set(:@cache, {})
    end

    it { expect(EncryptionService.pack('salt', 'value')).to eq 'salt.value' }
    it { expect(EncryptionService.pack('salt', nil)).to eq 'salt.' }
    it { expect(EncryptionService.pack('salt', '')).to eq 'salt.' }
  end

  context 'unpack' do
    before(:each) do
      EncryptionService.instance_variable_set(:@cache, {})
    end

    it { expect(EncryptionService.unpack('salt.value')).to eq ['salt', 'value'] }
    it { expect(EncryptionService.unpack('salt.value.value')).to eq ['salt', 'value.value'] }
    it { expect(EncryptionService.unpack(' salt.value')).to eq ['salt', 'value'] }
    it { expect(EncryptionService.unpack(' salt_underscore.value')).to eq ['salt_underscore', 'value'] }
    it { expect(EncryptionService.unpack('salt.')).to eq ['salt', ''] }
    it { expect { EncryptionService.unpack('salt') }.to raise_error('Invalid encrypted value: salt') }
  end

  context 'encrypt' do
    before(:each) do
      EncryptionService.instance_variable_set(:@cache, {})
    end

    let(:time) { Time.now.strftime('%Y%W') }
    it { expect(EncryptionService.encrypt('value')).to match(/#{time}/) }
  end

  context 'decrypt' do
    before(:each) do
      EncryptionService.instance_variable_set(:@cache, {})
    end

    let(:encrypted_key) { EncryptionService.encrypt('value') }
    it { expect(EncryptionService.decrypt(encrypted_key)).to eq 'value' }
  end

  context 'private methods' do
    context 'delete_expired_keys' do
      context 'ivalid cases' do
        context 'cache as number' do
          it 'shouldnt delete expired hash when hash is invalid' do
            EncryptionService.instance_variable_set(:@cache, 5)
            EncryptionService.send(:delete_expired_keys)
            expect(EncryptionService.instance_variable_get(:@cache)).to eq 5
          end
        end

        context 'empty hash' do
          it 'shouldnt delete expired hash when hash is invalid' do
            EncryptionService.instance_variable_set(:@cache, {})
            EncryptionService.send(:delete_expired_keys)
            expect(EncryptionService.instance_variable_get(:@cache)).to eq ({})
          end
        end

        context 'invalid hash' do
          it 'shouldnt delete expired hash when hash is invalid' do
            EncryptionService.instance_variable_set(:@cache, {'test': 'value'})
            EncryptionService.send(:delete_expired_keys)
            expect(EncryptionService.instance_variable_get(:@cache)).to eq ({'test': 'value'})
          end
        end

        context 'hash without expire date' do
          it 'shouldnt delete expired hash when hash is invalid' do
            EncryptionService.instance_variable_set(:@cache, {'test': {'key': 'generated_key'}})
            EncryptionService.send(:delete_expired_keys)
            expect(EncryptionService.instance_variable_get(:@cache)).to eq ({'test': {'key': 'generated_key'}})
          end
        end
      end

      context 'valid cases' do
        context 'should not delete keys' do
          it 'shouldnt delete hash keys' do
            EncryptionService.instance_variable_set(:@cache,
              {
                'test1': {key: 'generated_key', expire_date: Time.now + 3.hours },
                'test2': {key: 'generated_key', expire_date: Time.now + 2.hours },
                'test3': {key: 'generated_key', expire_date: Time.now + 1.hours },
              }.with_indifferent_access
            )
            EncryptionService.send(:delete_expired_keys)
            expect(EncryptionService.instance_variable_get(:@cache).keys).to match_array %w[test1 test2 test3]
          end
        end

        context 'should delete keys' do
          it 'should delete hash keys' do
            EncryptionService.instance_variable_set(:@cache,
              {
                'test1': {key: 'generated_key', expire_date: Time.now - 3.hours },
                'test2': {key: 'generated_key', expire_date: Time.now - 2.hours },
                'test3': {key: 'generated_key', expire_date: Time.now - 1.hours },
              }.with_indifferent_access
            )
            EncryptionService.send(:delete_expired_keys)
            expect(EncryptionService.instance_variable_get(:@cache)).to eq({})
          end
        end
      end
    end

    context 'get_master_key' do
      context 'empty cache' do
        it 'should generate key by salt' do
          EncryptionService.instance_variable_set(:@cache, {})
          key = EncryptionService.send(:get_master_key, 'salt')
          expect(EncryptionService.instance_variable_get(:@cache)['salt']['key']).to eq key
          expect(EncryptionService.instance_variable_get(:@cache)['salt']['expire_date'].to_date).to eq 1.week.from_now.to_date
        end
      end

      context 'non empty hash' do
        let(:values) {
          {
            "salt":{
              "key":         "\xD5\xD8e\\N{1}\xEB\x9DP\x033)\x10{X\x91\xA1V\xB7\xCC\xE1L2\xDF\xC5,\f\x1Fh\xC6",
              "expire_date": 1.week.from_now
            }
          }
        }

        it 'should get key from hash' do
          EncryptionService.instance_variable_set(:@cache, values)
          allow(Time).to receive(:now).and_return(1.week.ago)
          key = EncryptionService.send(:get_master_key, 'salt')
          expect(key).to eq values['salt']['key']
        end
      end
    end
  end
end
