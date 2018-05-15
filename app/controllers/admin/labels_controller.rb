# frozen_string_literal: true

module Admin
  class LabelsController < ModuleController
    before_action :find_account
    before_action :find_label, only: %i[edit update destroy]

    def new
      @label = @account.labels.new
    end

    def create
      @label = @account.labels.new(label_params)

      if @label.save
        redirect_to admin_account_path(@account), notice: 'Label was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @label.update(label_params)
        redirect_to admin_account_path(@account), notice: 'Label was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @label.destroy!
      redirect_to admin_account_path(@account), notice: 'Label was successfully destroyed.'
    end

  private

    def find_account
      @account = Account.kept.find(params[:account_id])
    end

    def find_label
      @label = @account.labels.find(params[:id])
    end

    def label_params
      params.require(:label).permit(:key, :value, :scope)
    end
  end
end
