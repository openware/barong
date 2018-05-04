# frozen_string_literal: true

class ProfileReviewMailer < ApplicationMailer
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
