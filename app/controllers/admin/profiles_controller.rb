# frozen_string_literal: true

module Admin
  class ProfilesController < ModuleController
    before_action :find_profile

    def edit
    end

    def update
      if @profile.update(profile_params)
        redirect_to admin_account_path(@profile.account), notice: 'Profile was successfully updated.'
      else
        render :edit
      end
    end

    def change_state
      if @profile.update(state: params[:state])
        redirect_to admin_account_path(@profile.account), notice: 'Profile was successfully updated.'
      else
        redirect_to admin_account_path
      end
    end

  private

    def find_profile
      @profile = Profile.find(params[:id])
    end

    def profile_params
      params.require(:profile)
            .permit(:first_name, :last_name,
                    :dob, :address, :postcode, :city, :country)
    end
  end
end
