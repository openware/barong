# frozen_string_literal: true

class AuthzController < ApplicationController
  before_action :authenticate_account!, unless: :public_route?
  skip_before_action :verify_authenticity_token

  PUBLIC_PATHS = [
    'diag',
    'ambassador',
    'accounts/sign_in',
    'accounts/sign_out',
    'accounts/sign_up',
    'health/alive',
    'health/ready'
  ]

  def verify
    return head(:ok) if public_route?

    response.set_header('Authorization', "Bearer #{create_token}")
    head :ok
  end

  private

  def create_token
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.first,
      current_account.id,
      Doorkeeper.configuration.scopes.to_s,
      2.minutes,
      false
    ).token
  end

  def public_route?
    logger.info "Authz request #{params.inspect}"
    PUBLIC_PATHS.any? { |path| params[:path].include?(path) }
  end
end
