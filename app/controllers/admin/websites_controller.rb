# frozen_string_literal: true

module Admin
  class WebsitesController < ModuleController
    before_action :set_website, only: %i[show edit update destroy]

    def index
      @websites = Website.all
    end

    def show
    end

    def new
      @website = Website.new
    end

    def edit
    end

    def create
      @website = Website.new(website_params)

      if @website.save
        redirect_to admin_websites_url, notice: 'Website was successfully created.'
      else
        render :new
      end
    end

    def update
      if @website.update(website_params)
        redirect_to admin_websites_url, notice: 'Website was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @website.destroy
      redirect_to admin_websites_url, notice: 'Website was successfully destroyed.'
    end

  private

    def set_website
      @website = Website.find(params[:id])
    end

    def website_params
      params.require(:website)
            .permit(:domain, :title, :logo, :stylesheet, :favicon,
                    :header, :footer, :redirect_url, :state)
    end
  end
end
