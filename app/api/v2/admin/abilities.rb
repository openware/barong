# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over abilities
      class Abilities < Grape::API
        namespace :abilities do
          desc 'Get all roles and permissions of barong cancan.'
          get do
            Ability.load_abilities
          end
        end
      end
    end
  end
end