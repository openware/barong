# frozen_string_literal: true

class IndexController < ApplicationController
  def index
    redirect_to new_account_session_url unless account_signed_in?
  end
end
