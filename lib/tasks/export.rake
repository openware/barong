# frozen_string_literal: true

require 'yaml'
require 'csv'

namespace :export do

  desc 'Export all users to csv file.'
  task users: :environment do
    count = 0
    errors_count = 0
    begin
      CSV.open('barong_users.csv', 'w') do |csv|
        csv << %w[uid email level role state]
        User.find_each do |user|
          csv << [user.uid, user.email, user.level, user.role, user.state]
          count += 1
        end
      rescue StandardError => e
        message = { error: e.message, email: user.email, uid: user.uid }
        Rails.logger.error message
        errors_count += 1
      end
    end
    Kernel.puts "Exported #{count} users"
    Kernel.puts "Errored #{errors_count}"
  end

end
