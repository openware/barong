# frozen_string_literal: true

class IndexController < ApplicationController
  def index
    return redirect_to new_account_session_url unless account_signed_in?

    redirect_to new_phone_path if current_account.level == 1
    redirect_to new_profile_path if current_account.level == 2 && current_account.documents.blank?
  end
end
