require 'spec_helper'

describe 'Registrations' do
  describe 'POST /api/registration' do
    let(:do_request) do
      post '/api/registration', params: params
    end

    before { do_request }

    context 'when email is invalid' do
      let(:params) { { email: 'bad_format' } }

      it 'renders an error' do
        expect_status_to_eq 422
        expect_body.to eq(error: ['Email is invalid'])
      end
    end

    context 'when email is blank' do
      let(:params) { { email: '' } }

      it 'renders an error' do
        expect_status_to_eq 422
        expect_body.to eq(error: ["Email can't be blank"])
      end
    end

    context 'when email is absent' do
      let(:params) {}

      it 'renders an error' do
        expect_status_to_eq 400
      end
    end

    context 'when email is valid' do
      let(:params) { { email: Faker::Internet.email } }

      it 'creates an account' do
        expect_status_to_eq 201
        expect_body.to eq('Account is created')
      end
    end
  end
end
