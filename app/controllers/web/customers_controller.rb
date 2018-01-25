module Web
  class CustomersController < ModuleController
    before_action :set_customer, only: [:show, :edit, :update, :destroy]

    # GET /customers
    def index
      @customers = Customer.all
    end

    # GET /customers/1
    def show
    end

    # GET /customers/new
    def new
      @customer = Customer.new
    end

    # GET /customers/1/edit
    def edit
    end

    # POST /customers
    def create
      @customer = Customer.new(customer_params)

      if @customer.save
        redirect_to new_document_path
      else
        render :new
      end
    end

    # PATCH/PUT /customers/1
    def update
      if @customer.update(customer_params)
        redirect_to @customer, notice: 'Customer was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /customers/1
    def destroy
      @customer.destroy
      redirect_to customers_url, notice: 'Customer was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_customer
        @customer = Customer.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def customer_params
        params.require(:customer).permit(:first_name, :last_name, :dob, :address, :postcode, :city, :country)
      end
  end
end
