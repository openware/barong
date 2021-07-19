# frozen_string_literal: true

module Barong
  class Signature
    BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.freeze
    SS58_PREFIX = 'SS58PRE'.freeze

    class <<self
      def transform_signature(signature)
        value = signature.delete_prefix('0x')
        val_length = value.length / 2
        buf_length = val_length.ceil
        array = Array.new(buf_length, 0)
        offset = [0, buf_length - val_length].max
        for i in (0...array.size)
          array[i + offset] = value.slice(i*2, 2).to_i(16)
        end

        # TODO here
        # identity.session.signature.invalid_signature_length
        raise StandartError unless array.length.in?([64, 65, 66])
        array.pack("C*")
      end

      def decode_address(address)
        decoded = base58_decode(address)

        allowed_encoded_lengths = [3, 4, 6, 10, 35, 36, 37, 38]
        # error!({ errors: ['identity.session.signature.invalid_signature_length'] }, 401)
        raise StandartError unless decoded.length.in?(allowed_encoded_lengths)

        is_valid, end_pos, ss58_length = check_address_checksum(decoded)

        # error!({ errors: ['identity.session.signature.invalid']
        raise StandartError unless is_valid


        decoded.slice(ss58_length, end_pos).pack("C*")
      end

      def base58_decode(encoded)
        basex_aphabet = BaseX.new(BASE58_ALPHABET)
        basex_aphabet.decode(encoded).unpack("C*")
      end

      def check_address_checksum(decoded)
        ss58Length = (decoded[0] & 0b0100_0000) == 0 ? 1 : 2
        # second_choice = [((decoded[0] & 0b0011_1111) << 2) | (decoded[1] >> 6) | ((decoded[1] & 0b0011_1111) << 8)].pack("l").unpack("l").first
        # ss58Decoded = ss58Length == 1 ? decoded[0] : second_choice
        isPublicKey = [34 + ss58Length, 35 + ss58Length].include?(decoded.length)
        length = decoded.length - (isPublicKey ? 2 : 1)

        hash = ssh_hash(decoded.slice(0, length))
        p hash
        is_valid = (decoded[0] & 0b1000_0000) === 0 && ![46, 47].include?(decoded[0]) && isPublicKey ?
            decoded[decoded.length - 2] === hash[0] && decoded[decoded.length - 1] === hash[1] :
            decoded[decoded.length - 1] === hash[0]

        return is_valid, length, ss58Length
      end

      def ssh_hash(key)
        hex_values = SS58_PREFIX.split('').collect { |char| "%2d" % [char.ord] }.map(&:to_i)

        u8uaConcat = hex_values.concat(key)

        byteLength = (512 / 8).ceil

        none_key = Blake2b::Key.none
        input = u8uaConcat.pack('c*').force_encoding('UTF-8')
        Blake2b.bytes(input, none_key, byteLength)
      end
    end

    # def self.base58_decode(address)
    # 	bits = 0
    # 	buffer = 0
    # 	written = 0
    # 	BASE32_ALPHABET = 'abcdefghijklmnopqrstuvwxyz234567'
    # 	BITS_PER_CHAR = 5
    # 	output = Array.new()
    # 	hash = BASE32_ALPHABET.split('').each_with_object({}).with_index do |(char, result), i|
    # 		result[i] = char
    # 	end

    # 	for i in (0...address.length)
    # 		lol = hash.key(address[i]).present? ? hash.key(address[i]) : 0
    # 		buffer = [(buffer << BITS_PER_CHAR) | lol].pack("l").unpack("l").first
    # 		bits += BITS_PER_CHAR

    # 		if (bits >= 8)
    # 			bits -= 8
    # 			output[written] = (0xff & (buffer >> bits))
    # 			written = written + 1
    # 		end
    # 	end
    # end
  end
end
