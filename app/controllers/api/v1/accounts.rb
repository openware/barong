# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Accounts < Grape::API

      desc 'Account related routes'
      resource :account do
        desc 'Return information about current resource owner'
        get '/' do
          current_account.as_json(only: %i[uid email level role state])
        end
      end
    end
  end
end
