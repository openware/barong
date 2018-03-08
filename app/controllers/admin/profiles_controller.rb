# frozen_string_literal: true

module Admin
  class ProfilesController < ModuleController

    def index
      params[:filter] = params[:filter] || 'pending'
      @profiles = Profile.all
      @profiles = @profiles.where(state: params[:filter]) if params[:filter].present?
      @profiles = @profiles.page(params[:page])
      @states   = @profiles.aasm.states.map(&:name)
    end

    def show
      @profile   = Profile.find(params[:id])
      @documents = @profile.documents
      @states    = @profile.aasm.states.map(&:name)
    end

    def change_state
      @profile = Profile.find(params[:id])
      if @profile.update(state: params[:event])
        redirect_to admin_profile_path(@profile), notice: 'Profile was successfully updated.'
      else
        redirect_to admin_profiles_path
      end
    end

  end
end
