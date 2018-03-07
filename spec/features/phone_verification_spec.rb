# frozen_string_literal: true

describe 'Phone verification' do
  let!(:account) { create :account, :confirmed }
  let!(:code) { Faker::Number.number(6) }

  before(:example) do
    sign_in account

    # Mock SMS
    allow_any_instance_of(Phone).to receive(:send_sms)
    allow_any_instance_of(Phone).to receive(:generate_code) { code }
  end

  it 'can access page' do
    expect(page).to have_content('Add mobile phone')
  end

  describe 'verify phone number' do
    context 'when number is invalid' do
      it 'shows an error' do
        fill_in 'number', with: 'qwerty'
        click_on 'Send code'
        expect(page).to have_content('invalid')
        # TODO: check if submit button is disabled
      end
    end

    context 'when the number is valid' do
      it 'shows an error' do
        fill_in 'number', with: '+380955555555'
        click_on 'Send code'
        expect(page).not_to have_content('invalid')
      end
    end
  end

  it 'creates phone' do
    fill_in 'number', with: '+380955555555'
    click_on 'Send code'

    fill_in 'Enter code', with: code
    click_on 'CONFIRM'

    expect(page).to have_content('Verification > Fill in personal information')
  end
end
