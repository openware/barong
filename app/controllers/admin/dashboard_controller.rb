# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    load_and_authorize_resource class: false
  end
end
