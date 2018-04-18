# frozen_string_literal: true

module Admin
  class ProfilesController < ModuleController

    def index
      params[:filter] = params[:filter] || 'pending'
      @profiles = Profile.all
      @profiles = @profiles.where(state: params[:filter]) if params[:filter].present?
      @profiles = @profiles.page(params[:page])
      @states = %w[created pending approved rejected]
    end

    def show
      @profile = Profile.find(params[:id])
      @documents = @profile.account.documents
      @states = %w[created pending approved rejected]
    end

    def change_state
      @profile = Profile.find(params[:id])
      if @profile.update(state: params[:state])
        redirect_to admin_profile_path(@profile), notice: 'Profile was successfully updated.'
      else
        redirect_to admin_profiles_path
      end
    end

  end
end
