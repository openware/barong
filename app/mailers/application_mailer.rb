# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include SkipEmails

  default from: ENV.fetch('SENDER_EMAIL', 'noreply@barong.io')
  layout 'mailer'

  def mail(options)
    send_email_if_enabled { super }
  end
end
