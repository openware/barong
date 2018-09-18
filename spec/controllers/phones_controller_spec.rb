# frozen_string_literal: true

RSpec.describe PhonesController, type: :controller do
  let!(:current_account) { create(:account) }
  let!(:level) { 1 }
  before do
    set_level(current_account, level)
    login_as current_account
  end

  describe '#new' do
    let(:do_request) { get :new }

    context 'when account level is not passed' do
      let!(:current_account) { create(:account) }
      let!(:level) { 0 }

      it 'redirects to index page' do
        do_request
        expect(response).to redirect_to index_path
      end
    end

    context 'when account level is passed' do
      it 'returns a success response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe '#create' do
    let(:do_request) { post :create, params: params }

    context 'when account level is not passed' do
      let(:params) { {} }
      let!(:current_account) { create(:account) }
      let!(:level) { 0 }

      it 'redirects to index page' do
        do_request
        expect(response).to redirect_to index_path
      end
    end

    context 'when account level is passed' do
      let(:phone_number) { '79265838671' }
      let(:verification_code) { '123456' }

      context 'when params are blank' do
        let(:params) { {} }

        it 'renders new action' do
          do_request
          expect(flash.now[:alert]).to eq('Verification code is invalid')
          expect(response).to render_template(:new)
        end
      end

      context 'when phones do not match' do
        let(:params) do
          { number: "+#{phone_number}" }
        end

        context 'when session is blank' do
          it 'renders new action' do
            do_request
            expect(flash.now[:alert]).to eq('Confirmation code was sent to another number')
            expect(response).to render_template(:new)
          end
        end

        context 'when session is not blank' do
          before { @request.session['phone'] = '7888' }
          it 'renders new action' do
            do_request
            expect(flash.now[:alert]).to eq('Confirmation code was sent to another number')
            expect(response).to render_template(:new)
          end
        end
      end

      context 'when phones match' do
        before { @request.session['phone'] = phone_number }
        let(:params) do
          {
            number: phone_number,
            code: verification_code
          }
        end

        context 'when session code is blank' do
          it 'renders new action' do
            do_request
            expect(flash.now[:alert]).to eq('Verification code is invalid')
            expect(response).to render_template(:new)
          end
        end

        context 'when user code does not match' do
          before { @request.session['verif_code'] = '123' }

          it 'renders new action' do
            do_request
            expect(flash.now[:alert]).to eq('Verification code is invalid')
            expect(response).to render_template(:new)
          end
        end

        context 'when user code does not match' do
          before { @request.session['verif_code'] = '123' }
          let(:verification_code) { '' }

          it 'renders new action' do
            do_request
            expect(flash.now[:alert]).to eq('Verification code is invalid')
            expect(response).to render_template(:new)
          end
        end

        context 'when user code matches' do
          before { @request.session['verif_code'] = verification_code }

          it 'redirects to profile page' do
            do_request
            expect(response).to redirect_to new_profile_path
          end

          it { expect { do_request }.to change { Phone.count }.by(1) }
          it { expect { do_request }.to change { current_account.reload.level }.to(2) }
        end
      end
    end
  end

  describe '#verify' do
    let(:do_request) { post :verify, params: params }
    let(:params) { { number: "+#{phone_number}" } }
    let(:phone_number) { '' }

    context 'when account level is not passed' do
      let!(:current_account) { create(:account) }
      let!(:level) { 0 }

      it 'redirects to index page' do
        do_request
        expect(response).to redirect_to index_path
      end
    end

    context 'when account level is passed' do
      context 'when number is blank' do
        it 'renders an error' do
          do_request
          expect_body.to eq(error: 'Phone is invalid')
        end
      end

      context 'when phone is invalid' do
        let(:phone_number) { '123' }

        it 'renders an error' do
          do_request
          expect_body.to eq(error: 'Phone is invalid')
        end
      end

      context 'when phone is valid' do
        let(:phone_number) { '79265838671' }

        context 'when phone is exists and verified' do
          let!(:exist_phone) do
            create(:phone, number: phone_number,
                           account: current_account,
                           validated_at: Time.current)
          end

          it 'renders an error' do
            do_request
            expect_body.to eq(error: 'Phone has already been used')
          end
        end

        context 'when phone is new' do
          it 'renders an error' do
            do_request
            expect_body.to eq(success: 'Code was sent')
          end

          it 'sends sms' do
            expect(PhoneUtils).to receive(:send_confirmation_sms)
            do_request
          end

          it 'saves session' do
            do_request
            expect(@request.session['verif_code']).to be
            expect(@request.session['phone']).to eq phone_number
          end
        end
      end
    end
  end
end
