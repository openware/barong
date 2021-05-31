# frozen_string_literal: true

require_dependency 'barong/seed'

seed = Barong::Seed.new
seed.seed_levels
seed.seed_permissions
seed.seed_users
seed.seed_restrictions

seed.seed_profiles
seed.seed_organizations
seed.seed_memberships

puts seed.inspect
