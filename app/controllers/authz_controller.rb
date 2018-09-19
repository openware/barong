# frozen_string_literal: true

class AuthzController < ApplicationController
  skip_before_action :verify_authenticity_token

  PUBLIC_PATHS = [
    'accounts/sign_in',
    'accounts/sign_out',
    'accounts/sign_up',
    'health/alive',
    'health/ready'
  ]

  def verify
    p current_account
    p account_signed_in?

    return head(:ok) if public_route?
    return invalid_login_attempt unless authenticate_account!

    response.set_header('Authorization', "Bearer #{create_token}")
    head :ok
  end

  private

  def create_token
    # JWT.encode(jwt_payload, Barong::Security.private_key, 'RS256')

    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.first,
      current_account.id,
      Doorkeeper.configuration.scopes.to_s,
      2.minutes,
      false
    ).token
  end

  def jwt_payload
    {
      iat: Time.current.to_i,
      exp: 2.minutes.to_i,
      sub: 'session',
      iss: 'barong',
      aud: 'peatio barong',
      jti: SecureRandom.hex(12).upcase,
      uid:   current_account.uid,
      email: current_account.email,
      role:  current_account.role,
      level: current_account.level,
      state: current_account.state
    }.freeze
  end

  def public_route?
    logger.info "Authz request #{params.inspect}"
    PUBLIC_PATHS.any? { |path| params[:path].include?(path) }
  end

  def invalid_login_attempt
    warden.custom_failure!
    render json: {message: "Require Authentication"}, status: 401
  end
end
