module Admin
  class WebsitesController < ModuleController
    before_action :set_website, only: [:show, :edit, :update, :destroy]

    # GET /admin/websites
    def index
      @websites = Website.all
    end

    # GET /admin/websites/1
    def show
    end

    # GET /admin/websites/new
    def new
      @website = Website.new
    end

    # GET /admin/websites/1/edit
    def edit
    end

    # POST /admin/websites
    def create
      @website = Website.new(website_params)

      if @website.save
        redirect_to admin_websites_url, notice: 'Website was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/websites/1
    def update
      if @website.update(website_params)
        redirect_to admin_websites_url, notice: 'Website was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/websites/1
    def destroy
      @website.destroy
      redirect_to admin_websites_url, notice: 'Website was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_website
        @website = Website.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def website_params
        params.require(:website).permit(:domain, :title, :logo, :stylesheet, :header, :footer, :redirect_url, :state)
      end
  end
end
