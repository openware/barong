# frozen_string_literal: true

module CountryHelper
  def display_country(selected_country: params[:country],
                      classes: 'form-control form-control-lg underlined')
    @countries = ISO3166::Country.all.sort
    collection_select(:profile, :country, @countries, :alpha3, :name,
                      { prompt: 'Select country', selected: selected_country },
                      class: classes)
  end
end
