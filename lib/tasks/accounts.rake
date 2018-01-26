namespace :accounts do

  desc 'Creating accounts with profiles'
  task create: :environment do

    ## Admin
    account = Account.create(email: 'admin@gmail.com', password: '123123', role: 'admin')
    account.update_attribute(:confirmed_at, account.created_at)

    profile = Profile.create(account: account, first_name: 'Paul', last_name: 'Walk', country: 'Country')

    ## Members
    [*1..30].each do |count|
      account = Account.create(email: "user#{count}@mail.com", password: '123123')
      account.update_attribute(:confirmed_at, account.created_at)

      case Random.rand(4)
        when 0
          state = 'created'
        when 1
          state = 'pending'

        when 2
          state = 'approved'

        when 3
          state = 'rejected'
      end

      profile = Profile.create(account: account, first_name: 'Paul', last_name: 'Walk', country: 'Country', state: state)

      [*0..Random.rand(3)].each do |count|
        profile.documents.create(upload_id: 'upload_id',
                                 upload_filename: 'upload_filename',
                                 upload_content_size: 'upload_content_size',
                                 upload_content_type: 'upload_content_type',
                                 doc_type: 'doc_type',
                                 doc_number: 'doc_number',
                                 doc_expire: Date.today + count.days)
      end
    end

  end

end