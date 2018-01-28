# frozen_string_literal: true

module Admin
  class ProfilesController < ModuleController

    def index
      @profiles = Profile.all
      @profiles = @profiles.where(state: params[:filter]) if params[:filter].present?
      @profiles = @profiles.page(params[:page])
      @states = Profile.group('state').pluck(:state)
    end

    def show
      @profile = Profile.find(params[:id])
      @documents = @profile.documents
      @states = Profile.group('state').pluck(:state)
    end

    def change_state
      @profile = Profile.find(params[:id])
      if @profile.update(state: params[:state])
        account = Account.find(@profile.account_id)
        account.increase_level
        redirect_to admin_profile_path(@profile), notice: 'Profile was successfully updated.'
      else
        redirect_to admin_profiles_path
      end
    end

  end
end
