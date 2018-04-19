# frozen_string_literal: true

class ProfileReviewMailer < ActionMailer::Base
  default from: ENV.fetch('SENDER_EMAIL', 'noreply@barong.io')

  def approved(account)
    @profile = account.profile
    @app_name = ENV.fetch('APP_NAME', 'Barong')
    mail(to: account.email, subject: 'Your identity was approved')
  end

  def rejected(account)
    @profile = account.profile
    @app_name = ENV.fetch('APP_NAME', 'Barong')
    mail(to: account.email, subject: 'Your identity was rejected')
  end
end
