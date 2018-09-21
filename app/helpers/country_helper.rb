# frozen_string_literal: true

module CountryHelper
  def display_country(selected_country: params[:country],
                      classes: 'form-control form-control-lg underlined')
    @countries = ISO3166::Country.all.sort
    collection_select(:profile, :country, @countries, :alpha3, :name,
                      {
                        prompt: 'Select country',
                        selected: country_to_alpha3(selected_country)
                      },
                      class: classes)
  end

  def country_to_alpha3(country_code)
    return unless country_code
    return Country[country_code]&.alpha3 if country_code.length == 2
    country_code
  end

  def full_country(country_code)
    country_code = country_to_alpha3(country_code)
    country = ISO3166::Country.find_country_by_alpha3(country_code)
    country.name
  end
end
