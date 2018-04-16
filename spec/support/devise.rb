# frozen_string_literal: true

module ControllerHelpers
  def login_as(account, params = {})
    @request.env['devise.mapping'] = Devise.mappings[:account]
    sign_in account || create(:account, params)
  end
end

module RequestHelpers
  def sign_in(account, params = {})
    visit index_path

    allow(Vault::TOTP).to receive(:server_available?) { true }

    fill_in 'account_email', with: params[:email] || account.email
    click_on 'Submit'

    fill_in 'otp', with: params[:otp] if params[:otp]

    fill_in 'account_password', with: params[:password] || account.password
    click_on 'Submit'
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :controller
  config.include RequestHelpers, type: :feature
end
