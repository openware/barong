# frozen_string_literal: true

namespace :activities do

  desc "Delete activities for specific period. From and To parameters should be on next format 'YYYY-mm-dd'"
  task :delete, [:from, :to] => [:environment] do |_, args|
    if args[:from].present? && args[:to].present?

      if valid_date?(args[:from]) && valid_date?(args[:to])
        activities = Activity.where('DATE(created_at) >= ? AND DATE(created_at) <= ?', args[:from].to_date, args[:to].to_date)

        puts "Found #{activities.count} activities to delete"
        activities.delete_all
      end
    else
      puts "There is no parameters (from, to)"
    end
  end

  def valid_date?(date)
    Date.parse(date)
    true
  rescue ArgumentError
    puts "Invalid date #{date}, should be 'YYYY-mm-dd''"
    false
  end
end
