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
      @document_label_value = @profile.account.labels.find_by(key: 'document', scope: 'private')&.value
    end

    def document_label
      account = @profile.account
      if account.add_level_label(:document, params[:state])
        redirect_to admin_profile_path(@profile), notice: 'Document label was successfully updated.'
      else
        redirect_to admin_profiles_path
      end
    end

  end
end
