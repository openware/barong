# frozen_string_literal: true

describe Barong::Authorize do
  class CustomTestSession < ActionController::TestSession
    include BitzlatoSession
    attr_accessor :claims
  end
  include_context 'geoip mock'

  describe "#cookie" do
    before do
      allow_any_instance_of(described_class).to receive(:validate_permissions!).and_return true
      allow_any_instance_of(described_class).to receive(:validate_session!).and_return true
    end

    let!(:create_member_permission) do
      create :permission,
             role: 'member',
             verb: 'all'
    end

    let(:session_id) { Rails.application.config.session_store.new(nil).generate_sid }
    let(:session_data) {
      { passport: { user: { idToken: jwt_payload }} }.with_indifferent_access
    }
    let(:request) do
      request = ActionDispatch::TestRequest.create
      request.cookies[Rails.application.config.session_store.new(nil).key] = session_id
      request.session = CustomTestSession.new session_data
      request.session.id = session_id
      request.session.claims = jwt_payload.with_indifferent_access
      request
    end

    subject do
      described_class.new(request, "").cookie_owner
    end

    context 'when user exists' do
      let(:user) { create :user }
      let(:jwt_payload) { { email: user.email, email_verified: true } }

      it { expect(subject).to eq(user) }
    end

    context 'when user not exists' do
      let(:jwt_payload) { { email: 'email@example.test', email_verified: true } }

      it { expect { subject }.to change { User.count}.by(1) }
      it { expect { subject }.to change { Label.count}.by(1) }
    end

    context 'when email not verified' do
      let(:jwt_payload) { { email: 'email@example.test', email_verified: false } }

      it { expect { subject }.to raise_error(Barong::Authorize::AuthError) }
    end

    context 'when no email key' do
      let(:jwt_payload) { { email_verified: true } }

      it { expect { subject }.to raise_error(Barong::Authorize::AuthError) }
    end
  end
end
