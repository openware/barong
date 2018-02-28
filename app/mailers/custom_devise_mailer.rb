# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  layout 'mailer'

  helper :mailer

  include Devise::Controllers::UrlHelpers

  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, opts={})
    headers['Domain-Name'] = opts[:domain]
    super
  end

  def email_changed(record, token, opts={})
    headers['Domain-Name'] = opts[:domain]
    super
  end

  def password_change(record, token, opts={})
    headers['Domain-Name'] = opts[:domain]
    super
  end

  def reset_password_instructions(record, token, opts={})
    headers['Domain-Name'] = opts[:domain]
    super
  end

  def unlock_instructions(record, token, opts={})
    headers['Domain-Name'] = opts[:domain]
    super
  end

end