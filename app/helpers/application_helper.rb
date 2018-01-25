# frozen_string_literal: true

module ApplicationHelper

  def formatted_date(date)
    date.strftime('%d/%m/%Y')
  end

  def document_type_list
    %w(ID-Card Passport Driver-License)
  end
end
