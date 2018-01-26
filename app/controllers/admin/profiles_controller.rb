# frozen_string_literal: true

module Admin
  class ProfilesController < ModuleController

    def index
      @profiles = Profile.all
      @profiles = @profiles.order(state: params[:filter] == 'state_desc' ? :asc : :desc) if params[:filter].present?
      @profiles = @profiles.page(params[:page])
    end

    def show
      @profile = Profile.find(params[:id])
      @documents = @profile.documents
    end

    def change_state
      @profile = Profile.find(params[:id])

      return if @profile.state == params[:state]

      @profile.update_column(:state, params[:state])

      redirect_to admin_profile_path(@profile)
    end

  end
end
