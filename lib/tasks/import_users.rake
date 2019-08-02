
#frozen_string_literal: true

require 'csv'

namespace :import do
  # Detailed instruction https://github.com/rubykube/barong/blob/master/docs/tasks/import.md
  # Required fields for import users:
  # - uid
  # - email
  #
  # Usage:
  # For import users: -> bundle exec rake import:users['file_name.csv']

  desc 'Load users from csv file.'
  task :users, [:config_load_path] => [:environment] do |_, args|
    csv_table = File.read(Rails.root.join(args[:config_load_path]))
    import_user_log = File.open('./log/import_users.log', 'w')
    count = 0
    CSV.parse(csv_table, :headers => true).map do |row|
      row = row.to_h.compact.symbolize_keys!
      defaults = { level: 0, role: 'member', state: 'pending', password: generate_password }
      permitted_attr = %i[uid email role state]
      User.new(row.slice(*permitted_attr)
          .reverse_merge(defaults))
          .save!
      count += 1
    rescue StandardError => e
      message = { error: e.message, email: row[:email], uid: row[:uid] }
      import_user_log.write(message.to_yaml + "\n")
    end
    import_user_log.close
    Kernel.puts "Created #{count} members"
    Kernel.puts "Errored #{CSV.parse(csv_table, headers: true).count - count}"
  end

  # Required fields for import referrals:
  # - uid
  # - referral_uid
  #
  # Usage:
  # For import users: -> bundle exec rake import:fill_referals['file_name.csv']

  desc 'users referral relation from csv file'
  task :fill_referrals, [:config_load_path] => [:environment] do |_, args|
    csv_table = File.read(Rails.root.join(args[:config_load_path]))
    import_affiliates_log = File.open('./log/import_referrals.log', 'w')
    count = 0
    CSV.parse(csv_table, :headers => true).map do |row|
      row = row.to_h.compact.symbolize_keys!
      user = User.find_by_uid!(row[:uid])
      target_user = User.find_by_uid(row[:referral_uid])
      next unless target_user

      user.update!(referral_id: target_user.id)
      count += 1
    rescue StandardError => e
      message = { error: e.message, email: row[:email], uid: row[:uid], referral_uid: row[:referral_uid] }
      import_affiliates_log.write(message.to_yaml + "\n")
    end
    import_affiliates_log.close
    Kernel.puts "Created #{count} referrals"
  end

  def generate_password
    chars = ('a'..'z').to_a
    numbers = ('0'..'9').to_a
    special = %w[! @ # $ % & / ( ) + ? *]
    chars.sort_by { rand }.join[0..3] + chars.sort_by { rand }.join[0..3].upcase + numbers.sort_by { rand }.join[0..3] + special.sort_by { rand }.join[0..3]
  end
end
