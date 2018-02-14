# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[edit update destroy]
  before_action :authenticate_account!

  # GET /profiles/new
  def new
    if current_account.level < 2
      redirect_to new_phone_path
    else
      @profile = Profile.new
    end
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles
  # rubocop:disable Style/IfUnlessModifier
  def create
    profile = Profile.new(profile_params)
    unless profile.save
      return redirect_to new_profile_url, notice: 'Some fields are empty or invalid'
    end

    document = Document.new(doc_params.merge(profile_id: profile.id))
    unless document.save
      return redirect_to new_profile_url, notice: 'Some fields are empty or invalid'
    end

    redirect_to index_url
  end
  # rubocop:enable Style/IfUnlessModifier

  # PATCH/PUT /profiles/1
  def update
    if @profile.update(profile_params)
      redirect_to index_path, notice: 'Profile was successfully updated.'
    else
      render :edit
    end
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
    params.require(:profile)
          .permit(:account_id, :first_name, :last_name, :dob, :address, :postcode, :city, :country)
          .merge(account_id: current_account.id)
  end

  def doc_params
    params.require(:profile).permit(:doc_number, :upload)
  end
end
