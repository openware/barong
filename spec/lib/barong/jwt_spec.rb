# frozen_string_literal: true

require_dependency 'barong/jwt'

describe Barong::JWT do
  let(:key) { OpenSSL::PKey::RSA.generate(2048) }

  it 'should encode payload with claims' do
    codec = Barong::JWT.new(key: key)
    token = codec.encode({hello: 'world'})

    decoded = ::JWT.decode(token, key.public_key,
                           true, { algorithm: 'RS256' })
    expect(decoded.first.fetch('hello')).to eq('world')
  end
end
