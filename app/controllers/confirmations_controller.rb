# frozen_string_literal: true

require 'uri'

class ConfirmationsController < Devise::ConfirmationsController
private

  def after_confirmation_path_for(resource_name, resource)
    return super if params[:redirect_uri].blank? || ENV['DOMAIN_NAME'].blank?
    domain = URI(params[:redirect_uri]).host
    root_domain = PublicSuffix.parse(domain).domain
    return params[:redirect_uri] if ENV['DOMAIN_NAME'] == root_domain

    super
  end
end
