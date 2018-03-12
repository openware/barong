# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[edit update destroy]
  before_action :authenticate_account!

  # GET /profiles/new
  def new
    redirect_to new_document_path if Profile.find_by_account_id(current_account.id)
    if current_account.level < 2
      redirect_to new_phone_path
    else
      @profile = Profile.new
    end
  end

  # POST /profiles
  def create
    begin
      @profile = Profile.new(profile_params)
      @profile.account_id = current_account.id
      @profile.validate!
      green_id_status = GreenId.new().register(@profile.account_id, profile_params)
      if @profile.update!(green_id_status: green_id_status )
        redirect_to new_document_path
      end
    rescue ActiveRecord::RecordInvalid
      flash[:alert] = 'Some fields are empty or invalid'
      return render :new
    end

    redirect_to new_document_path
  end

  # DELETE /profiles/1
  def destroy
    @profile.destroy
    redirect_to profiles_url, notice: 'Profile was successfully destroyed.'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def profile_params
    params.require(:profile).permit(:account_id,
      :first_name, :last_name, :middle_name,
      :dob, :flat_number, :street_number,
      :street_name, :street_type, :postcode,
      :suburb, :address_state, :country)
  end
end
