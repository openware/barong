# frozen_string_literal: true

module CountryHelper
  def display_country
    @countries = ISO3166::Country.all.each { |c| pp [c.alpha3, c.local_name] }
    collection_select(:profile, :country, @countries, :alpha3, :local_name,
      { include_blank: 'Country' }, { class: 'form-control form-control-lg underlined' })
  end
end
