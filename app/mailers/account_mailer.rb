# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  include SkipEmails

  def confirmation_instructions(record, token, opts = {})
    send_email_if_enabled { super }
  end

  def reset_password_instructions(record, token, opts = {})
    EventAPI.notify(
      'system.account.reset_password_token',
      uid: record.uid,
      email: record.email,
      token: token
    )
    send_email_if_enabled { super }
  end

  def unlock_instructions(record, token, opts = {})
    EventAPI.notify(
      'system.account.unlock_token',
      uid: record.uid,
      email: record.email,
      token: token
    )
    send_email_if_enabled { super }
  end

  def email_changed(record, opts = {})
    send_email_if_enabled { super }
  end

  def password_change(record, opts = {})
    send_email_if_enabled { super }
  end
end
