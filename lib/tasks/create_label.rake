# Rake for- if user level is < 3 and he already has labels "email" and "
# phone" we should make him level 3 and give him "bank_account" label
# For import users: -> bundle exec rake user_level_create['file_name.csv']
# To run this rake task uid must be present in the csv file.
require 'csv'

desc 'Make user level 3 and give him "bank_account" label, If user level is < 3 and he already has labels "email" and "phone"'
task :create_label, %i[config_load_path key value scope description] => :environment do |_, args|
  csv_file = File.read(Rails.root.join(args[:config_load_path]))
  import_user_level_create_log = File.open('./log/import_user_level_create.log', 'w')
  count = 0
  errors_count = 0
  CSV.parse(csv_file, :headers => true).map do |row|
    row = row.to_h.compact.symbolize_keys!
    user = User.find_by_uid!(row[:uid])
    next unless user

    if user.level < 3 && (user.labels.map(&:key) & %w[email phone]) == %w[email phone]
      user.labels.create(key: args[:key], value: args[:value], scope: args[:scope], description: args[:description])
      user.update!(level: 3, state: 'active')
      count += 1
    end
  rescue StandardError => e
    errors_count += 1
    message = { error: e.message }
    import_user_level_create_log.write(message.to_yaml + "\n")
  end
  import_user_level_create_log.close
  Kernel.puts "Make #{count} users levels"
  Kernel.puts "Errored #{errors_count}"
end
