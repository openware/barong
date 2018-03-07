# frozen_string_literal: true

describe 'Sign in' do
  let!(:account) { create :account, :confirmed }

  it 'allows to sign in with email and password' do
    sign_in account
    expect(page).to have_content 'Signed in successfully'
  end

  it 'blocks account when system detects too many sign in attempts' do
    visit index_path
    expect {
      Devise.maximum_attempts.times do
        sign_in account, password: '11111111'
      end
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(account.reload.locked_at?).to be_truthy
  end

  context 'with OTP' do
    let!(:otp) { Faker::Number.number(6) }

    before(:example) do
      allow(Vault::TOTP).to receive(:exist?).and_return(true)
      allow(Vault::TOTP).to receive(:validate?) { |_, code| otp == code }
    end

    it 'allows to sign in with OTP' do
      sign_in account, otp: otp
      expect(page).to have_content('Signed in successfully')
    end

    it 'displays an error if OTP is wrong' do
      sign_in account, otp: '123456'
      expect(page).to have_content('Wrong Google Auth code')
    end
  end

end
