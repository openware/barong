# frozen_string_literal: true

describe 'Api::V1::Profiles' do
  include_context 'bearer authentication'

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

    describe 'POST /api/v2/resource/users/activity' do
      let(:do_request) do
        put '/api/v2/resource/users/password', params: params, headers: auth_header
      end

      it 'allows only [password, otp, session, all] as a topic parameter' do
        get '/api/v2/resource/users/activity/invalid', headers: auth_header
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ['resource.user.wrong_topic'])

        get '/api/v2/resource/users/activity/session', headers: auth_header
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ['resource.user.no_activity'])
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
          expect_body.to eq(errors: ["password.requirements", "password.password.password_strength"])
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
end
