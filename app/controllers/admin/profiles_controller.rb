# frozen_string_literal: true

module Admin
  class ProfilesController < ModuleController
    def index
      @profiles = Profile.all.page(params[:page])
    end

    def show
      @profile = Profile.find(params[:id])
      @documents = @profile.account.documents
      @labels = @profile.account.labels
    end

    def document_label
      account = @profile.account
      if account.labels.find_or_create_by(key: :document).update(value: params[:state])
        redirect_to admin_profile_path(@profile), notice: 'Document label was successfully updated.'
      else
        redirect_to admin_profiles_path
      end
    end

  end
end
