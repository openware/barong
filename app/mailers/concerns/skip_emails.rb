# frozen_string_literal: true

module SkipEmails
  extend ActiveSupport::Concern

  def send_email_if_enabled
    raise 'Block is required' unless block_given?

    if ENV['SKIP_EMAILS']
      return Rails.logger.info 'Emails are skip. You need to use Event API to handle emails manually'
    end

    yield
  end
end
