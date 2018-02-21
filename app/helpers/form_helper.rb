# frozen_string_literal: true

module FormHelper

  def get_countries
    [
      ["Australia", "AUS"]
    ]
  end

  def get_states_for_profile
    states = [
      ["Australian Capital Territory", "ACT"],
      ["Northern Territory", "NT"],
      ["New South Wales", "NSW"],
      ["Queensland", "QLD"],
      ["Tasmania", "TAS"],
      ["South Australia", "SA"],
      ["Victoria", "VIC"],
      ["Western Australia", "WA"]
    ]
    states.sort
  end

  def get_states_for_documents
    states = [
      ["Australian Capital Territory", "actregodvs"],
      ["Northern Territory", "ntregodvs"],
      ["New South Wales", "nswregodvs"],
      ["Queensland", "qldregodvs"],
      ["Tasmania", "tasregodvs"],
      ["South Australia", "saregodvs"],
      ["Victoria", "vicregodvs"],
      ["Western Australia", "waregodvs"]
    ]
    states.sort
  end

  def get_id_types
    id_types = [
      ["Driver license", "DL"],
      ["Passport", "P"]
    ]
    id_types.sort

    #['Driver license', 'Passport', 'Utility bill']
  end

end