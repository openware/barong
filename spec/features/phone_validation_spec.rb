# frozen_string_literal: true

describe 'Phone validation' do
  include PhoneUtils

  PHONES = {
    '+380919442222' =>      true,
    '+38(095) 756 45 67' => true,
    '+917020472888' =>      true,
    '+33672722218' =>       true,
    '+79265838671' =>       true,
    '77055003366' =>        true,
    '66652126434' =>        true,
    '+80919442202' =>       false,
    '0919442202' =>         false,
    '+0919442202' =>        false
  }.freeze

  it 'should do something' do
    PHONES.each { |phone, validated| expect(PhoneUtils.valid?(phone)).to eq validated }
  end
end
