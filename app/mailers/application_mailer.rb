# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # default from: 'from@example.com'
  layout 'mailer'
  add_template_helper(MailerHelper)
end
