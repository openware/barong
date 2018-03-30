# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  private

  def after_confirmation_path_for(resource_name, resource)
    return params[:redirect_uri] if ENV['DOMAIN_NAME'].present? &&
                                    params[:redirect_uri].ends_with(".#{ENV['DOMAIN_NAME']}")

    new_session_path(resource_name)
  end
end
