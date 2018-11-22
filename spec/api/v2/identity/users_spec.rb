# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Identity::Users do
  describe 'POST /api/v2/identity/users' do
    let(:do_request) do
      post '/api/v2/identity/users', params: params
    end

    context 'when email is invalid' do
      let(:params) { { email: 'bad_format', password: 'Password1', recaptcha_response: 'valid_responce' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: ['Email is invalid','Password is too weak'])
      end
    end

    context 'when Password is invalid' do
     let(:params) { { email: 'vadid.email@gmail.com', password: 'password', recaptcha_response: 'valid_responce' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: ['Password does not meet the minimum requirements','Password is too weak'])
      end
    end

    context 'when email and password are absent' do
      let(:params) {}

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: 'email is missing, email is empty, password is missing, password is empty, recaptcha_response is missing')
      end
    end

    context 'when email is blank' do
      let(:params) { { email: '', password: 'zieV0Kai', recaptcha_response: 'valid_responce'  } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: 'email is empty')
      end
    end

    context 'when email is valid' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ', recaptcha_response: 'valid_responce'  } }

      it 'creates an account' do
        do_request
        expect_status_to_eq 201
      end
    end
  end

  describe 'POST /api/v2/identity/users/email/generate_code' do
    let(:params) {{ email: 'invalid@email.com' }}
    let(:do_request) { post '/api/v2/identity/users/email/generate_code', params: params}

    context 'when user is invalid' do
      it 'renders an error' do
        do_request
        expect(status).to eq 422
        expect(json_body[:error]).to eq("User doesn't exist or has already been activated")
      end
    end

    let(:params) {{ email: 'valid-confirmed@email.com' }}
    context 'when user is valid, email confirmed' do
      it 'renders an error' do
        create(:user, email:'valid-confirmed@email.com', state:'active')
        do_request
        expect(status).to eq 422
        expect(json_body[:error]).to eq("User doesn't exist or has already been activated")
      end
    end

    context 'when user is valid' do
      let(:user) { create(:user, state:'pending')}
      let(:params) {{ email: user.email }}
      it 'returns a success' do
        do_request
        expect(status).to eq 201
      end
    end
  end

    describe 'POST /api/v2/identity/users/email/confirm_code' do
      let(:do_request) { post '/api/v2/identity/users/email/confirm_code', params: params}
      let(:params) {{}}

      context 'when token is missing' do
        it 'returns an error' do
          do_request
          expect(json_body[:error]).to eq("token is missing, token is empty")
          expect(status).to eq 400
        end
      end

      context 'when token is invalid' do
        let(:params) {{ token: 'invalid token' }}

        it 'returns an error' do
          do_request
          expect(json_body[:error]).to eq("Failed to decode and verify JWT")
          expect(status).to eq 403
        end
      end

      context 'when token is valid' do
        let(:user) { create(:user, state:'pending',email:'valid_email@email.com')}
        let(:params) {{ token: codec.encode(sub: 'confirmation', email: user.email, uid: user.uid)}}
        it 'updates state to active' do
          do_request
          expect(status).to eq 201
        end
      end
    end

  describe 'POST /api/v2/identity/users/password/generate_code' do
    let(:do_request) do
      post '/api/v2/identity/users/password/generate_code', params: params
    end
    let(:params) { { email: email } }

    context 'when email is unknown' do
      let(:email) { 'unknown@gmail.com' }

      it 'renders not found error' do
        do_request
        expect_body.to eq(error: "User doesn't exist")
        expect(response.status).to eq(404)
      end
      end

    context 'when user is found by email' do
      let!(:user) { create(:user, email: email) }
      let(:email) { 'email@gmail.com' }

      it 'sends reset password instructions' do
        do_request
        expect(response.status).to eq(201)
      end
    end
  end

  describe 'PUT /api/v2/identity/users/password/confirm_code' do
    let(:do_request) do
      post '/api/v2/identity/users/password/confirm_code', params: params
    end
    let(:params) do
      {
        reset_password_token: reset_password_token,
        password: password,
        confirm_password: confirm_password
      }
    end
    let(:reset_password_token) { '' }
    let(:password) { '' }
    let(:confirm_password) { '' }

    context 'when params are blank' do
      it 'renders 400 error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(error: 'reset_password_token is empty, password is empty, confirm_password is empty')
      end
    end

    context 'when Reset Password Token is invalid' do
      let(:reset_password_token) { 'invalid' }
      let(:password) { 'Gol4aid2' }
      let(:confirm_password) { 'Gol4aid2' }

      it 'renders 403 error' do
        do_request
        expect(response.status).to eq(403)
        expect_body.to eq(error: 'Failed to decode and verify JWT')
      end
    end

    context 'when Reset Password Token is valid' do
      let!(:user) { create(:user) }
      let(:reset_password_token) { codec.encode(sub:'reset', email: user.email, uid: user.uid) }
      let(:password) { 'ZahSh8ei' }
      let(:confirm_password) { 'ZahSh8ei' }
      let(:log_in) { post '/api/v2/identity/sessions', params: { email: user.email, password: password } }

      it 'resets a password' do
        do_request
        expect(response.status).to eq(201)
        log_in
        expect(response.status).to eq(200)
      end
    end

    context 'When Reset Password Token is valid, passwords don\'t match' do
      let!(:user) { create(:user) }
      let(:reset_password_token) { codec.encode(sub:'reset', email: user.email, uid: user.uid) }
      let(:password) { 'ZahSh8exwdi' }
      let(:confirm_password) { 'ZahSh8ei' }

      it 'returns 422 error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(error: 'Passwords don\'t match')
      end
    end
  end
end
