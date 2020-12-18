# frozen_string_literal: true

namespace :permissions do
  desc 'Reload user permissions'
  task reload: :environment do
    Permission.transaction do
      # Delete old permissions
      Permission.delete_all
      # Clean permissions cache
      Rails.cache.delete('permissions')
      # Load permissions
      Barong::Seed.new.seed_permissions
    end
  end
end
