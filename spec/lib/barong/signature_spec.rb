# frozen_string_literal: true


describe Barong::Signature do
  describe 'signature_verify?' do
    it 'should verify signature' do
      message = 'hello world'
      signature = '0x299d3bf4c8bb51af732f8067b3a3015c0862a5ff34721749d8ed6577ea2708365d1c5f76bd519009971e41156f12c70abc2533837ceb3bad9a05a99ab923de06'
      address = 'DxN4uvzwPzJLtn17yew6jEffPhXQfdKHTp2brufb98vGbPN'
      expect(Barong::Signature.signature_verify?(message, signature, address)).to eq true
    end
  end

  describe 'transform_signature' do
    context 'non hex value' do
      it 'without 0x' do
        signature = '9ecfe998'
        expect { Barong::Signature.transform_signature(signature) }.to raise_error(StandardError, 'invalid hex value')
      end

      it 'od length' do
        signature = '0x9ecfe99'
        expect { Barong::Signature.transform_signature(signature) }.to raise_error(StandardError, 'invalid hex value')
      end
    end

    context 'invalid signature length' do
      it do
        signature = '0x9ecfe998'
        expect { Barong::Signature.transform_signature(signature) }.to raise_error(StandardError, 'invalid signature length')
      end
    end

    context 'successfully transform signature' do
      let(:signature) { '0x9ecfe998ac57c57a231e84666a82ebb08efa22e0afa73e5477b5ffd9bd0463da1caaec2842f26be879a9a74ce7015691e7bd7196f13f452fc0ad0e536e956800' }

      it do
        result = Barong::Signature.transform_signature(signature).unpack('C*')
        expected_result = [158, 207, 233, 152, 172, 87, 197, 122, 35, 30, 132, 102, 106, 130, 235, 176, 142, 250, 34, 224, 175, 167, 62, 84, 119, 181, 255, 217, 189, 4, 99, 218, 28, 170, 236, 40, 66, 242, 107, 232, 121, 169, 167, 76, 231, 1, 86, 145, 231, 189, 113, 150, 241, 63, 69, 47, 192, 173, 14, 83, 110, 149, 104, 0]

        expect(result).to eq expected_result
      end
    end
  end

  describe 'blake2_as_hex' do
    it 'convert value to blake2b hex' do
      message = '#7afCsF79sa2ATqLjZpAUHXip8YeWo7D4pzgoBbjiwnJeRxi#1623693678'
      expected_result = '0x1b2f4b26bed46554df19eefe25c4d7df75360786cc9cca1112c2e103503732cc'
      expect(Barong::Signature.blake2_as_hex(message)).to eq expected_result
    end
  end

  describe 'base58_decode' do
    it 'invalid character' do
      encoded = '#D6zxeKkx3upT3mr39zLRqvEXfKBkaA9PJCubZhr8PBAPTSy'
      expect { Barong::Signature.send(:base58_decode, encoded) }.to raise_error(StandardError, 'character is not included in base58 alphabet')
    end

    it 'nil value' do
      expect { Barong::Signature.send(:base58_decode, nil) }.to raise_error(StandardError, 'character is not included in base58 alphabet')
    end

    it 'should decode from base58 address' do
      encoded = 'D6zxeKkx3upT3mr39zLRqvEXfKBkaA9PJCubZhr8PBAPTSy'
      expected_result = [2, 23, 102, 35, 24, 116, 36, 76, 250, 70, 75, 177, 244, 238, 109, 114, 194, 25, 168, 190, 154, 249, 142, 200, 44, 179, 83, 217, 215, 167, 7, 165, 197, 12, 202]
      expect(Barong::Signature.send(:base58_decode, encoded)).to eq expected_result
    end
  end

  describe 'ssh_hash' do
    it 'should transform to ssh_hash' do
      array = [2, 79, 210, 176, 173, 75, 86, 57, 131, 171, 245, 205, 47, 128, 51, 192, 162, 60, 80, 54, 241, 59, 108, 93, 239, 82, 103, 56, 103, 114, 177, 186, 215]
      expected_result = [183, 69, 36, 221, 178, 7, 10, 6, 94, 156, 6, 207, 244, 191, 128, 194, 102, 225, 228, 29, 131, 122, 32, 11, 39, 231, 24, 89, 94, 102, 117, 92, 149, 5, 60, 222, 232, 51, 21, 197, 247, 121, 121, 183, 206, 56, 101, 74, 232, 11, 12, 104, 79, 130, 57, 124, 200, 97, 239, 128, 109, 228, 48, 172]
      expect(Barong::Signature.send(:ssh_hash, array)).to eq expected_result
    end
  end

  describe 'check_addres_checksum' do
    it 'should check address checksum' do
      decoded = [2, 79, 210, 176, 173, 75, 86, 57, 131, 171, 245, 205, 47, 128, 51, 192, 162, 60, 80, 54, 241, 59, 108, 93, 239, 82, 103, 56, 103, 114, 177, 186, 215, 183, 69]
      expect(Barong::Signature.send(:check_address_checksum, decoded)).to eq([true, 33, 1])
    end
  end

  describe 'decode address' do
    context 'invalid checksum' do
      it 'shoudl raise an error' do
        address = 'BNytVvDN5YhQAzSMRQ7gb8RTWuoETu7yW4aGb96FN5VPuzU'
        expect { Barong::Signature.decode_address(address) }.to raise_error(StandardError, 'invalid decoded address checksum')
      end
    end

    it 'invalid decoded address length' do
      address = 'KNytVvDN5YQQAzSMRQ7gb8RTWuoETu7yW4aGb96FN5VPuz'
      expect { Barong::Signature.decode_address(address) }.to raise_error(StandardError, 'invalid decoded address length')
    end

    it 'should decode address' do
      address = 'ENytVvDN5YQQAzSMRQ7gb8RTWuoETu7yW4aGb96FN5VPuzU'
      expected_result = [79, 210, 176, 173, 75, 86, 57, 131, 171, 245, 205, 47, 128, 51, 192, 162, 60, 80, 54, 241, 59, 108, 93, 239, 82, 103, 56, 103, 114, 177, 186, 215]
      expect(Barong::Signature.decode_address(address).unpack('C*')).to eq expected_result
    end
  end
end
