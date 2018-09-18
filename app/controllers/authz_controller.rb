# frozen_string_literal: true

class AuthzController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_account!, unless: :public_route?

  PUBLIC_PATHS = [
    'diag',
    'ambassador',
    'accounts/sign_in',
    'accounts/sign_out',
    'accounts/sign_up',
    'health/alive',
    'health/ready'
  ].freeze

  def verify
    jwt_token = JWT.encode(jwt_payload, Barong::Security.private_key, 'RS256')
    response.set_header('Authorization', "Bearer #{jwt_token}")
    head :ok
  end

private

  def jwt_payload
    {
      iat: Time.current.to_i,
      exp: 2.minutes.from_now.to_i,
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
end
