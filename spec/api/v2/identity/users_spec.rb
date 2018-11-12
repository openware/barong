# frozen_string_literal: true

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
        expect_body.to eq(error: ['Email is invalid'])
      end
    end

    # WIP: we doesnt have any password validations yet
    # context 'when Password is invalid' do
    #   let(:params) { { email: 'vadid.email@gmail.com', password: 'password', recaptcha_response: 'valid_responce' } }

    #   it 'renders an error' do
    #     do_request
    #     expect_status_to_eq 422
    #     expect_body.to eq(error: ['Password does not meet the minimum system requirements. It should be composed of uppercase and lowercase letters, and numbers.', 'Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.'])
    #   end
    # end

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
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCu', recaptcha_response: 'valid_responce'  } }

      it 'creates an account' do
        do_request
        expect_status_to_eq 201
      end
    end
  end
end