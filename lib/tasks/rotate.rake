#frozen_string_literal: true

namespace :rotate do
  desc 'Rotate profile keys'
  task profiles: :environment do
    Profile.find_each(batch_size: 100) do |profile|
      profile.update({})
    end
  end

  desc 'Rotate phones keys'
  task phones: :environment do
    Phone.find_each(batch_size: 100) do |phone|
      phone.update({})
    end
  end

  desc 'Rotate documents keys'
  task documents: :environment do
    Document.where.not(doc_number_encrypted: nil).find_each(batch_size: 100) do |document|
      document.update({})
    end
  end
end
