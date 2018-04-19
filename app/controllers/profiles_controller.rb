# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_if_profile_created
  before_action :check_account_level

  def new
    @profile = current_account.build_profile
  end

  def create
    @profile = current_account.create_profile(profile_params)

    if @profile.errors.any?
      flash[:alert] = 'Some fields are empty or invalid'
      return render :new
    end

    redirect_to new_document_path
  end

private

  def redirect_if_profile_created
    redirect_to new_document_path if current_account.profile
  end

  def check_account_level
    redirect_to new_phone_path if current_account.level < 2
  end

  def profile_params
    params.require(:profile)
          .permit(:first_name, :last_name,
                  :dob, :address, :postcode, :city, :country)
  end
end
