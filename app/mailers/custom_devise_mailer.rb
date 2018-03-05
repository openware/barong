# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  layout 'mailer'

  helper :mailer

  include Devise::Controllers::UrlHelpers

  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, opts = {})
    key = "confirmation_instructions_#{record.email}_domain"
    headers['Domain-Name'] = Rails.cache.read(key)
    Rails.cache.delete(key)
    super
  end

  def reset_password_instructions(record, token, opts = {})
    key = "reset_password_instructions_#{record.email}_domain"
    headers['Domain-Name'] = Rails.cache.read(key)
    Rails.cache.delete(key)
    super
  end

  def unlock_instructions(record, token, opts = {})
    key = "unlock_instructions_#{record.email}_domain"
    headers['Domain-Name'] = Rails.cache.read(key)
    Rails.cache.delete(key)
    super
  end

end
