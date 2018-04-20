# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :authenticate_account!
  before_action :check_account_level

  def new
    @document = current_account.documents.new
  end

  def create
    @document = current_account.documents.new(document_params)
    if @document.save
      redirect_to index_path, notice: 'Document was successfully created.'
    else
      flash[:alert] = 'Some fields are empty or invalid'
      render :new
    end
  end

private

  def check_account_level
    redirect_to new_phone_path if current_account.level < 2
  end

  def document_params
    params.require(:document)
          .permit(:doc_type, :doc_number, :doc_expire, :upload)
  end
end
