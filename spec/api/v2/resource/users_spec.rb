# frozen_string_literal: true

describe 'Api::V1::Profiles' do
  include_context 'bearer authentication'
  include_context 'geoip mock'

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  describe 'GET /api/v2/resource/users/me' do
    it 'should reply permissions denied' do
      get '/api/v2/resource/users/me'
      expect_body.to eq(errors: ["jwt.decode_and_verify"])
      expect(response.status).to eq(401)
    end

    it 'should allow traffic with Authorization' do
      get '/api/v2/resource/users/me', headers: auth_header
      expect(json_body[:email]).to eq(test_user.email)
      expect(response.status).to eq(200)
    end
  end

  let(:valid_otp_code) { '1357' }
  let(:invalid_otp_code) { '1234' }

  before do
    allow(TOTPService).to receive(:validate?)
      .with(test_user.uid, valid_otp_code) { true }
    allow(TOTPService).to receive(:validate?)
      .with(test_user.uid, invalid_otp_code) { false }
  end

  describe 'PUT /api/v2/resource/users/me' do
    let(:correct_data) { { bar: 'baz' }.to_json }
    let(:incorrect_data) { 'random string' }

    it 'changes user data field' do
      put '/api/v2/resource/users/me', headers: auth_header, params: {
        data: correct_data
      }
      expect(test_user.reload.data).to eq(correct_data)
      expect(response.status).to eq 200
    end

    it 'receives invalid data error' do
      put '/api/v2/resource/users/me', headers: auth_header, params: {
        data: incorrect_data
      }

      expect(response.status).to eq 422
      expect_body.to eq errors: ['data.invalid_format']
    end
  end

  describe 'DELETE /api/v2/resource/users/me' do
    it 'receives invalid password error' do
      delete '/api/v2/resource/users/me', headers: auth_header, params: {
        password: 'WrongPassword'
      }

      expect(response.status).to eq 422
      expect(test_user.reload.state).to eq 'active'
      expect_body.to eq errors: ['resource.user.invalid_password']
    end

    it 'receives otp missing error if 2fa is enabled and param is missing' do
      test_user.update(otp: true)
      delete '/api/v2/resource/users/me', headers: auth_header, params: {
        password: 'Tecohvi0'
      }

      expect(response.status).to eq 422
      expect(test_user.reload.state).to eq 'active'
      expect_body.to eq errors: ['resource.user.missing_otp_code']
    end

    it 'receives otp empty error if 2fa is enabled  and param is empty' do
      test_user.update(otp: true)
      delete '/api/v2/resource/users/me', headers: auth_header, params: {
        password: 'Tecohvi0',
        otp_code: ''
      }

      expect(response.status).to eq 422
      expect(test_user.reload.state).to eq 'active'
      expect_body.to eq errors: ['resource.user.empty_otp_code']
    end

    it 'receives invalid otp error with wrong otp code' do
      test_user.update(otp: true)
      delete '/api/v2/resource/users/me', headers: auth_header, params: {
        password: 'Tecohvi0',
        otp_code: invalid_otp_code
      }

      expect(response.status).to eq 422
      expect(test_user.reload.state).to eq 'active'
      expect_body.to eq errors: ['resource.user.invalid_otp']
    end

    it 'marks user as deleted with turned on 2fa and valid otp' do
      test_user.update(otp: true)
      delete '/api/v2/resource/users/me', headers: auth_header, params: {
        password: 'Tecohvi0',
        otp_code: valid_otp_code
      }

      expect(response.status).to eq 200
      expect(test_user.reload.state).to eq 'deleted'
    end

    it 'marks user as deleted with turned off 2fa' do
      delete '/api/v2/resource/users/me', headers: auth_header, params: {
        password: 'Tecohvi0'
      }

      expect(response.status).to eq 200
      expect(test_user.reload.state).to eq 'deleted'
    end
  end

  describe 'POST /api/v2/resource/otp/disable' do
    let(:valid_otp_code) { '1357' }
    let(:invalid_otp_code) { '1234' }

    before do
      allow(TOTPService).to receive(:validate?)
        .with(test_user.uid, valid_otp_code) { true }
      allow(TOTPService).to receive(:validate?)
        .with(test_user.uid, invalid_otp_code) { false }
    end

    it 'with dasbled 2fa' do
      post '/api/v2/resource/otp/disable', headers: auth_header, params: { code: valid_otp_code }
      expect_body.to eq errors: ['resource.otp.not_enabled']
    end

    it 'with invalid code' do
      test_user.update(otp: true)
      post '/api/v2/resource/otp/disable', headers: auth_header, params: { code: invalid_otp_code }
      expect_body.to eq errors: ['resource.otp.invalid']
    end

    it 'disables 2fa' do
      test_user.update(otp: true)
      expect {
        post '/api/v2/resource/otp/disable', headers: auth_header, params: { code: valid_otp_code }
      }.to change { test_user.reload.otp }.from(true).to(false)

      expect(response.status).to eq 200
    end
  end

  describe 'POST /api/v2/resource/users/activity' do
    it 'allows only [password, otp, session, all] as a topic parameter' do
      get '/api/v2/resource/users/activity/invalid', headers: auth_header
      expect(response.status).to eq(422)
      expect_body.to eq(errors: ['resource.user.wrong_topic'])
      get '/api/v2/resource/users/activity/session', headers: auth_header
      expect(response.status).to eq(422)
      expect_body.to eq(errors: ['resource.user.no_activity'])
    end
    it 'sorts user activities' do
      4.times { create(:activity, user: test_user) }
      get '/api/v2/resource/users/activity/all', headers: auth_header
      activities = JSON.parse(response.body)
      expect(activities.first['id']).to be >= activities.last['id']
    end
    it 'sorts user activities by result' do
      4.times { create(:activity, user: test_user, result: 'succeed') }
      get '/api/v2/resource/users/activity/all', params: { result: 'succeed' }, headers: auth_header
      activities = JSON.parse(response.body)
      expect(activities.length).to eq(4)
    end
    it 'sorts user activities by time range' do
      4.times { create(:activity, user: test_user, result: 'succeed') }
      get '/api/v2/resource/users/activity/all', params: { time_from: 5.hours.ago.to_i, time_to: 1.hours.ago.to_i }, headers: auth_header
      activities = JSON.parse(response.body)
      expect(activities.length).to eq(1)
    end

    it 'sorts user activities by time range' do
      4.times { create(:activity, user: test_user, result: 'succeed') }
      4.times { create(:activity, user: test_user, result: 'succeed', created_at: 10.hours.ago) }

      get '/api/v2/resource/users/activity/all', params: { time_from: 5.hours.ago.to_i}, headers: auth_header
      activities = JSON.parse(response.body)
      expect(activities.length).to eq(4)
    end
  end

  describe 'POST /api/v2/resource/users/password' do
    let(:do_request) do
      put '/api/v2/resource/users/password', params: params, headers: auth_header
    end
    let(:params) do
      {
        old_password: old_password,
        new_password: new_password,
        confirm_password: confirm_password
      }
    end
    let(:old_password) { '' }
    let(:new_password) { '' }
    let(:confirm_password) { '' }
    context 'when params are blank' do
      it 'renders 400 error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.user.empty_old_password", "resource.user.empty_new_password", "resource.user.empty_confirm_password"])
      end
    end
    context 'when old password is not right' do
      let(:old_password) { 'invalid' }
      let(:new_password) { 'Gol4aid2' }
      let(:confirm_password) { 'Gol4aid2' }
      it 'renders 400 error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(errors: ["resource.password.prev_pass_not_correct"])
      end
    end
    context 'when new pass and confirmation are different' do
      let(:old_password) { 'Tecohvi0' } # 'Tecohvi0' - test_user password
      let(:new_password) { 'Gol4aid1' }
      let(:confirm_password) { 'Gol4aid2' }
      it 'renders 422 error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.password.doesnt_match"])
      end
    end
    context 'when params are valid, passwords are weak' do
      let(:old_password) { 'Tecohvi0' } # 'Tecohvi0' - test_user password
      let(:new_password) { 'Simple' }
      let(:confirm_password) { 'Simple' }
      it 'returns weak password error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["password.requirements"])
      end
    end
    context 'when params are valid' do
      let(:old_password) { 'Tecohvi0' } # 'Tecohvi0' - test_user password
      let(:new_password) { 'Gol4aid1' }
      let(:confirm_password) { 'Gol4aid1' }
      let(:log_in) { post '/api/v2/identity/sessions', params: { email: test_user.email, password: new_password } }
      it 'changes a password' do
        do_request
        expect(response.status).to eq(201)
        log_in
        expect(response.status).to eq(200)
      end
    end
  end
end

