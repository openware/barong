# Pass csv file with list of users csv as args: bundle exec rake apply_labels\[users.csv,"phone","verified","private","description"\]
# To run this rake task uid must be present in the csv file.

# CSV example
#
# uid
# ID872B23C35E,
# ID90CB56514D

require 'csv'

desc 'Apply a label to a list of users'
task :apply_labels, %i[users_csv_file key value scope description] => :environment do |_, args|
  csv_file = File.read(Rails.root.join(args[:users_csv_file]))
  log = File.open('./log/apply_labels.log', 'w')
  count = 0
  errors_count = 0
  CSV.parse(csv_file, :headers => true).map do |row|
    row = row.to_h.compact.symbolize_keys!
    user = User.find_by_uid!(row[:uid])
    next unless user

    user.labels.create(key: args[:key], value: args[:value], scope: args[:scope], description: args[:description])
    count += 1
  rescue StandardError => e
    errors_count += 1
    message = { error: e.message }
    log.write(message.to_yaml + "\n")
  end
  log.close
  puts "Applied label to #{count} users with #{errors_count} error(s)"
end
