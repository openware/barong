# frozen_string_literal: true

describe API::V2::Identity::Sessions do
  describe 'POST /api/v2/sessions' do
    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:uri) { '/api/v2/sessions' }
    subject!(:user) do
      create :user,
             email: email,
             password: password,
             password_confirmation: password
    end
    let(:otp_enabled) { false }

    context 'With valid params' do
      let(:do_request) { post uri, params: params }
      let(:params) do
        {
          email: email,
          password: password
        }
      end

      it 'Checks current credentials and returns session' do
        do_request
        expect(session[:uid]).to eq(user.uid)
        expect_status.to eq(200)

        # Make a succed request somewhere
        # expect(response.status).to eq(200)
      end

      let(:recaptcha_response) { nil }
      let(:valid_response) { 'valid' }
      let(:invalid_response) { 'invalid' }

      before do
        allow_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha)
        .with(model: user,
              skip_remote_ip: true,
              response: valid_response) { true }
        
        allow_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha)
        .with(model: user,
              skip_remote_ip: true,
              response: invalid_response) { raise StandardError }
      end

      context 'when captcha response is blank' do
        let(:params) do
          {
            email: email,
            password: password,
            recaptcha_response: recaptcha_response
          }
        end
        # WIP: need a logic for captcha on signin
        # it 'renders an error' do
        #   do_request
        #   expect(json_body[:error]).to eq('recaptcha_response is required')
        #   expect_status_to_eq 420
        # end
      end

      context 'when captcha response is not valid' do
        let(:params) do
          {
            email: email,
            password: password,
            recaptcha_response: invalid_response
          }
        end

        before do
          expect_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha) { false }
        end

        it 'renders an error' do
          do_request
          expect(json_body[:error]).to eq('reCAPTCHA verification failed, please try again.')
          expect_status_to_eq 422
        end
      end

      context 'when captcha response is valid' do
        let(:params) do
          {
            email: email,
            password: password,
            recaptcha_response: valid_response
          }
        end

        before do
          expect_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha) { true }
        end
      end

      # context 'when account has enabled 2FA' do
      # end

      # context 'when user has less than 5 failed attempts' do
      # end
    end

    context 'With Invalid params' do
      context 'Checks current credentials and returns error' do
        it 'when email, password is missing' do
          post uri
          expect_body.to eq(error: 'email is missing, password is missing')
          expect(response.status).to eq(400)
        end

        it 'when password is missing' do
          post uri, params: { email: email }
          expect_body.to eq(error: 'password is missing')
          expect(response.status).to eq(400)
        end

        context 'when Password is wrong' do
          it 'returns errror' do
            post uri, params: { email: email, password: 'password' }
            expect_body.to eq(error: 'Invalid Email or Password')
            expect(response.status).to eq(401)
          end

          # it 'locks account if user has 5 failed attempts' do
          # end
        end
      end
    end

    context 'When user has not verified his email or banned' do
      let!(:another_email) { 'email@random.com' }
      let!(:user_banned) do
        create :user,
               email: another_email,
               password: password,
               password_confirmation: password,
               state: "banned"
      end

      it 'returns error on banned user' do
        post uri, params: { email: another_email, password: password }
        expect_body.to eq(error: 'Your account is not active')
        expect(response.status).to eq(401)
      end

      it 'returns error on pending user' do
        user_banned.update(state: 'pending')
        expect(user_banned.state).to eq('pending')

        post uri, params: { email: another_email, password: password }
        expect_body.to eq(error: 'Your account is not active')
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'DELETE /api/v2/sessions' do
    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:uri) { '/api/v2/sessions' }
    let(:params) do
      {
        email: email,
        password: password
      }
    end
    subject!(:user) do
      create :user,
             email: email,
             password: password,
             password_confirmation: password
    end
    context 'With valid session' do
      let(:do_create_session_request) { post uri, params: params }
      let(:do_delete_session_request) { delete uri }

      it 'Deletes session' do
        do_create_session_request
        expect(session[:uid]).to eq(user.uid)

        do_delete_session_request
        expect(session[:uid]).to eq(nil)
      end
    end
  end
end
