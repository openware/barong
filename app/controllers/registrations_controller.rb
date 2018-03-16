# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :check_sign_up, only: %i[new create]

  def check_sign_up
    # TODO: Here should value that admin can change in the admin panel
    # TODO: Right now it is just boolean value for tests

    registrations_is_enabled = true

    redirect_to index_path, alert: 'Sorry. Registrations disabled' if registrations_is_enabled
  end

end