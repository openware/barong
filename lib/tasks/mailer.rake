# frozen_string_literal: true

require 'ostruct'

namespace 'mailer' do
  desc 'Generate email to the user with UID'
  task :send, [:uid] => [:environment] do |_t, args|
    record = OpenStruct.new
    record.user = User.find_by(uid: args[:uid])
    record.domain = 'barong.io'
    record.token = 'TEST_TOKEN'

    params = {
      subject: 'Test Message',
      template_name: 'email_confirmation.en.html.erb',
      record: record,
      logo: Barong::App.config.smtp_logo_link,
      changes: nil,
      user: record.user,
      signature: 'signature'
    }

    Postmaster.process_payload(params).deliver_now
  end
end
