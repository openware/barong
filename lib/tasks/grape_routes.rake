# frozen_string_literal: true

namespace :grape do
  desc "API Routes"
  task save_routes: :environment do
    File.open('grape_routes', 'w') do |file|
      $stdout = file
      Rake::Task['grape:routes'].invoke
    end
  end
end
