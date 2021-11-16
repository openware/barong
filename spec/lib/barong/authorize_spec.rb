# frozen_string_literal: true

describe Barong::Authorize do
  include_context 'geoip mock'

  describe "#bz_cookie" do
    let!(:create_member_permission) do
      create :permission,
             role: 'member',
             verb: 'all'
    end

    let(:request) do
      double(
        headers: {},
        cookies: { 'bitzlatoId' => 'sess:xxx.xxxxxx'},
        remote_ip: '85.140.0.148',
        env: { 'HTTP_USER_AGENT': 'blabla'}
      )
    end

    subject { described_class.new(request, "") }

    def auth!(jwt_payload = {})
      allow_any_instance_of(Barong::BitzlatoSession).to receive(:id_token)
      allow(Barong::Auth0::JWT).to receive(:verify).and_return([jwt_payload.with_indifferent_access])

      subject.bz_cookie_owner
    end

    #it 'call bz_cookie_owner' do
    #  expect(subject).to receive(:bz_cookie_owner)
    #  auth!
    #end

    context 'when user exists' do
      let(:user) { create :user }
      let(:payload) { {email: user.email, email_verified: true} }

      it { expect(auth!(payload)).to eq(user) }
    end

    context 'when user not exists' do
      let(:payload) { {email: 'email@example.test', email_verified: true} }

      it { expect { auth!(payload) }.to change { User.count}.by(1) }
      it { expect { auth!(payload) }.to change { Label.count}.by(1) }
    end

    context 'when email not verified' do
      let(:payload) { {email: 'email@example.test', email_verified: false} }

      it { expect { auth!(payload) }.to raise_error(Barong::Authorize::AuthError) }
    end

    context 'when no email key' do
      let(:payload) { { email_verified: true } }

      it { expect { auth!(payload) }.to raise_error(Barong::Authorize::AuthError) }
    end
  end
end
