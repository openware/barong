# frozen_string_literal: true

namespace :account do
  desc 'Adds missing labels to account corresponding to his level'
  task add_missing_labels: :environment  do
    Account.find_each do |acc|
      acc.level.times do |lvl|
        level = Level.all[lvl]
        raise "Account with id #{acc.id} has a level which is not corresponding the levels database" if level.nil?
        Label.find_or_create_by(account: acc, scope: 'private', key: level.key, value: level.value)
      end
    end
  end

  desc 'Set account\'s level corresponding to his labels'
  task update_level_with_labels: :environment  do
    Account.find_each(&:update_level)
  end
end
