# frozen_string_literal: true

module ApplicationHelper
  def inject_css

    website = Website.find_by_domain(ApplicationHelper::DOMAIN)

    return  (website.nil? || website.stylesheet.empty?) ? "" : website.stylesheet
  end
end
