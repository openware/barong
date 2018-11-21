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

  describe 'POST /api/v2/identity/users/generate_confirmation' do
    let(:params) {{ email: 'invalid@email.com' }}
    let(:do_request) { post '/api/v2/identity/users/generate_confirmation', params: params}
    
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

    describe 'POST /api/v2/identity/users/confirm' do
      let(:do_request) { post '/api/v2/identity/users/confirm', params: params}

      context 'when token is missing' do
        it 'returns an error' do
          do_request
          expect(json_body[:error]).to eq("confirmation_token is missing, confirmation_token is empty")
          expect(status).to eq 400
        end
      end

      context 'when token is invalid' do
        let(:params) {{ confirmation_token: 'invalid token' }}

        it 'returns an error' do
          do_request
          expect(json_body[:error]).to eq("Failed to decode and verify JWT")
          expect(status).to eq 422
        end
      end
      
      context 'when token is valid' do
        let(:user) { create(:user, state:'pending',email:'valid_email@email.com')}
        let(:params) {{ confirmation_token: confirm_codec.encode({email: user.email,uid: user.uid}.as_json)}}
        it 'updates state to active' do
          do_request
          expect(status).to eq 201
        end
      end
    end
  end
end
