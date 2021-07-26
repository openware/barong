# frozen_string_literal: true

module Barong
  class Signature
    POSSIBLE_SIGNATURE_LENGTH = [64, 65, 66].freeze
    ALLOWED_ENCODED_ADDRESS_LENGTH = [3, 4, 6, 10, 35, 36, 37, 38].freeze
    BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.freeze
    SS58_PREFIX = 'SS58PRE'.freeze

    class <<self
      def signature_verify?(message, signature, public_key)
        signature = transform_signature(signature)
        public_key = decode_address(public_key)

        # verify signature with Ed25519 algorithm
        verify_key = Ed25519::VerifyKey.new(public_key)
        verify_key.verify(signature, message)
      rescue StandardError, Ed25519::VerifyError => e
        Rails.logger.error(e.message)
        false
      end

      def transform_signature(signature)
        # verify hex value
        pattern = /^0x[a-fA-F0-9]+$/
        signature_check = (signature.match?(pattern) || signature == '0x') && signature.length % 2 == 0
        raise StandardError, 'invalid hex value' unless signature_check

        value = signature.delete_prefix('0x')
        # convert to hex string
        hex_value = [value].pack('H*')
        # transform hex string to byte array
        length = hex_value.bytes.to_a.length
        raise StandardError, 'invalid signature length' unless length.in?(POSSIBLE_SIGNATURE_LENGTH)

        hex_value
      end

      def decode_address(address)
        decoded = base58_decode(address)
        raise StandardError, 'invalid decoded address length' unless decoded.length.in?(ALLOWED_ENCODED_ADDRESS_LENGTH)

        is_valid, end_pos, ss58_length = check_address_checksum(decoded)
        raise StandardError, 'invalid decoded address checksum' unless is_valid

        decoded.slice(ss58_length, end_pos - 1).pack('C*')
      end

      def blake2_as_hex(message, bit_length = 256)
        byte_length = (bit_length / 8).ceil
        none_key = Blake2b::Key.none
        '0x' + Blake2b.hex(message, none_key, byte_length)
      end

      private

      def base58_decode(encoded)
        raise StandardError, 'character is not included in base58 alphabet' unless validate_base58(encoded)
        # second params is alphabet representation
        # https://github.com/dougal/base58/blob/master/lib/base58.rb#L11
        Base58.base58_to_binary(encoded, :bitcoin).unpack('C*')
      end

      def validate_base58(encoded)
        return unless encoded.present?

        # validate if characters are existing in base58 alphabet
        encoded.chars.all? { |char| BASE58_ALPHABET.include?(char) }
      end

      def check_address_checksum(decoded)
        ss58_length = (decoded[0] & 0b0100_0000) == 0 ? 1 : 2

        # 32/33 bytes public + 2 bytes checksum + prefix
        is_public_key = [34 + ss58_length, 35 + ss58_length].include?(decoded.length)
        length = decoded.length - (is_public_key ? 2 : 1)

        # calculate the hash and do the checksum byte checks
        hash = ssh_hash(decoded.slice(0, length))

        check = is_public_key ? decoded[decoded.length - 2] == hash[0] && decoded[decoded.length - 1] == hash[1]
                                :
                                decoded[decoded.length - 1] == hash[0]
        is_valid = (decoded[0] & 0b1000_0000) == 0 && ![46, 47].include?(decoded[0]) && check

        return is_valid, length, ss58_length
      end

      def ssh_hash(key, bit_length = 512)
        byte_length = (bit_length / 8).ceil
        str_value = key.pack('C*')

        none_key = Blake2b::Key.none
        # input should consists of ss58 prefix and string value of key
        input = str_value.prepend(SS58_PREFIX)
        Blake2b.bytes(input, none_key, byte_length)
      end
    end
  end
end
