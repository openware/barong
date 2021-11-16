# frozen_string_literal: true

describe Barong::BitzlatoSession do
  let(:secret) { 'secret' }
  let(:session_id) { '123' }
  let(:user_id) { 1 }
  let(:id_token) { "123123qweqwe" }
  let(:raw_sesion_data) do
    {
      passport: {
        user: {
          userId: user_id,
          idToken: id_token,
        }
      }
    }.to_json
  end
  let(:cookie) { described_class.generate_cookie(session_id, secret) }
  subject { described_class.new(secret: secret, cookie: cookie ) }

  before do
    allow_any_instance_of(Redis).to receive(:get) { raw_sesion_data }
  end

  it 'returns valid true' do
    expect(subject.valid?).to be_truthy
  end

  it 'returns user id' do
    expect(subject.user_id).to eq(user_id)
  end

  it 'return id token' do
    expect(subject.id_token).to eq(id_token)
  end
end
