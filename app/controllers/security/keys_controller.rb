# frozen_string_literal: true

module Security
  class KeysController < ApplicationController

    def index
      @keys = Key.page(params[:page])
    end

    def new
      @key = Key.new
    end

    def create
      @key = Key.new(key_params)

      if @key.save
        redirect_to security_keys_path, notice: 'Key was successfully created.'
      else
        flash[:alert] = 'Some fields are empty or invalid'
        render :new
      end
    end

    def destroy
      @key = Key.find(params[:id])
      @key.destroy
      redirect_to security_keys_path, notice: 'Key was successfully destroyed.'
    end

    def key_params
      params.require(:key).permit(:label, :token, :rake_limit)
    end
  end
end
