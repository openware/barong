# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    module Admin
      class Websites < Grape::API
        desc 'Websites related routes'
        resource :websites do
          desc 'Return list of websites'
          get '/' do
            Website.all.as_json(only: %i[domain title logo stylesheet header footer redirect_url state])
          end

          desc 'Create new website'
          post '/new' do
            Website.create\
              domain:       params[:domain],
              title:        params[:title],
              logo:         params[:logo],
              stylesheet:   params[:stylesheet],
              header:       params[:header],
              footer:       params[:footer],
              redirect_url: params[:redirect_url],
              state:        params[:state]
          end
        end
      end
    end
  end
end
