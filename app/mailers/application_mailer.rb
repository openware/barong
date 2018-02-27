# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def email_notify(profile)
    @profile = profile
    @account = profile.account
    mail(to: @account.email, subject: 'Approved email')
  end
end
