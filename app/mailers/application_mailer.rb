# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Barong.config.email.default_from
  layout 'mailer'
end
