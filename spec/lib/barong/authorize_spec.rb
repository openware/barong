# frozen_string_literal: true

describe Barong::Authorize do
  include_context 'geoip mock'

  describe "#bz_cookie" do
    let!(:create_member_permission) do
      create :permission,
             role: 'member',
             verb: 'all'
    end

    let(:secret) { ENV.fetch('P2P_SESSION_SECRET') }
    let(:session_id) { 'session_id' }
    let(:request) do
      request = ActionDispatch::TestRequest.create
      request.cookies[ENV['P2P_SESSION_COOKIE']] = Barong::BitzlatoSession.generate_cookie(session_id, secret)
      request.session = ActionController::TestSession.new
      request.session.id = session_id
      request
    end

    def auth!(jwt_payload = {})
      session_data = {}
      session_data[:passport] = { user: { userId: 1, idToken: jwt_payload.to_json } }

      allow_any_instance_of(Redis).to receive(:get) { session_data.to_json }
      allow(Barong::Auth0::JWT).to receive(:verify).and_return([jwt_payload.with_indifferent_access])

      described_class.new(request, "").bz_cookie_owner
    end

    context 'when user exists' do
      let(:user) { create :user }
      let(:jwt_payload) { { email: user.email, email_verified: true } }

      it { expect(auth!(jwt_payload)).to eq(user) }
    end

    context 'when user not exists' do
      let(:jwt_payload) { { email: 'email@example.test', email_verified: true } }

      it { expect { auth!(jwt_payload) }.to change { User.count}.by(1) }
      it { expect { auth!(jwt_payload) }.to change { Label.count}.by(1) }
    end

    context 'when email not verified' do
      let(:jwt_payload) { { email: 'email@example.test', email_verified: false } }

      it { expect { auth!(jwt_payload) }.to raise_error(Barong::Authorize::AuthError) }
    end

    context 'when no email key' do
      let(:jwt_payload) { { email_verified: true } }

      it { expect { auth!(jwt_payload) }.to raise_error(Barong::Authorize::AuthError) }
    end
  end
end
