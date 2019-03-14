# frozen_string_literal: true

module Api
  module V3
    module Admin
      class UsersController < ApplicationController
        # GET /v3/admin/users
        def index
          limit_page
          # binding.pry
          render json: User.all
        end

        private

        def limit_page
          params.require([:limit, :page])
        end
      end
    end
  end
end
