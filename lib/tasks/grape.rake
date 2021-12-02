# frozen_string_literal: true

namespace :grape do
  desc "API Routes"
  task routes: :environment do
    File.open('grape_routes', 'w') do |file|
      API::V2::Base.routes.each do |api|
        method = api.request_method.ljust(10)
        path = api.path
        file.write("#{method} #{path}\n")
      end
    end
  end
end
