# frozen_string_literal: true

# Trick or treat (get a JWT for a cookie)
class AuthzController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_account!, unless: :public_route?

  PUBLIC_PATHS = [
    'ambassador',
    'accounts/sign_in',
    'accounts/sign_in/confirm',
    'accounts/sign_out',
    'accounts/sign_up',
    'health/alive',
    'health/ready'
  ].freeze

  def verify
    unless public_route?
      jwt_token = JWT.encode(jwt_payload, Barong::Security.private_key, 'RS256')
      Rails.logger.info { jwt_token }
      response.set_header('Authorization', "Bearer #{jwt_token}")
    end

    head :ok
  end

private

  def jwt_payload
    {
      iat: Time.current.to_i,
      exp: 15.seconds.from_now.to_i,
      sub: 'session',
      iss: 'barong',
      aud: 'peatio barong',
      jti: SecureRandom.hex(12).upcase,
      uid: current_account.uid,
      email: current_account.email,
      role: current_account.role,
      level: current_account.level,
      state: current_account.state
    }.freeze
  end

  def public_route?
    request.format.symbol.in?(%i[css ico js png jpeg]) || PUBLIC_PATHS.include?(params[:path])
  end
end
