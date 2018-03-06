# frozen_string_literal: true

class KeypairsController < ApplicationController

  def index
    @keypairs = Keypair.page(params[:page])
  end

  def new
    @keypair = Keypair.new
  end

  def create
    @keypair = Keypair.new(keypair_params)

    if @keypair.save
      redirect_to keypairs_path, notice: 'Keypair was successfully created.'
    else
      flash[:alert] = 'Some fields are empty or invalid'
      render :new
    end
  end

  def destroy
    @keypair = Keypair.find(params[:id])
    @keypair.destroy
    redirect_to keypairs_path, notice: 'Keypair was successfully destroyed.'
  end

  def keypair_params
    params.require(:keypair).permit(:label, :token, :rake_limit)
  end

end
