# frozen_string_literal: true
#require "savon"

class GreenId

  def register(verification_id, params)
    dob = params[:dob].to_date

    message = {
      :accountId => "lexiumcapital",
      :password => "5n2-QBN-QdR-APM",
      :verificationId => verification_id,
      :ruleId => "Default",
      :name =>
      {
        :givenName => params[:first_name],
        :middleNames => params[:middle_name],
        :surname => params[:last_name]
      },
      :currentResidentialAddress =>
      {
        :flatNumber => params[:flat_number], :streetNumber => params[:street_number],
        :streetName => params[:street_name], :streetType => params[:street_type],
        :suburb => params[:suburb], :postcode => params[:postcode],
        :state => params[:address_state], :country => params[:country]
      },
      :dob =>
      {
        :day => dob.strftime("%d"),
        :month => dob.strftime("%m"),
        :year => dob.strftime("%Y")
      }
    }

    client = Savon.client do
      wsdl "https://test-au.vixverify.com/Registrations-Registrations/DynamicFormsServiceV3?WSDL"
      #log true
    end

    response = client.call(:register_verification, message: message)

    xml_doc = Nokogiri::XML(response.to_s)
    xml_doc.remove_namespaces!
    xml_doc.xpath("//registerVerificationResponse/return/verificationResult/overallVerificationStatus").text

  rescue Savon::SOAPFault => e
    Rails.logger.error("[Greed Id register_verification Service SOAPFault] %s" % [e.message])
    "SOAPFault"
  end

  def submit_id_details(verification_id, profile, params)

    source_id = get_source_id(params)

    message = {
      :accountId => 'lexiumcapital',
      :password => "5n2-QBN-QdR-APM",
      :verificationId => verification_id,
      :sourceId => source_id,
      :inputFields =>
      {
        :input =>
          [
            {
              :name => "greenid_#{source_id}_number",
              :value => params[:doc_number]
            },
            {
              :name => "greenid_#{source_id}_givenname",
              :value => profile.first_name
            },
            {
              :name => "greenid_#{source_id}_middlename",
              :value => profile.middle_name
            },
            {
              :name => "greenid_#{source_id}_surname",
              :value => profile.last_name
            },
            {
              :name => "greenid_#{source_id}_dob",
              :value => profile.dob.strftime("%d/%m/%Y")
            },
            {
              :name => "greenid_#{source_id}_tandc",
              :value => "on"
            }
          ]
      }
    }

    client = Savon.client do
      wsdl "https://test-au.vixverify.com/Registrations-Registrations/DynamicFormsServiceV3?WSDL"
      log true
    end

    response = client.call(:set_fields, message: message)

    xml_doc = Nokogiri::XML(response.to_s)
    xml_doc.remove_namespaces!

    xml_doc.xpath("//setFieldsResponse/return/verificationResult/overallVerificationStatus").text

  rescue Savon::SOAPFault => e
    Rails.logger.error("[Greed Id service set_fields driving license SOAPFault] %s" % [e.message])
    "SOAPFault"
  end

  def get_source_id(params)
    if params[:doc_type] == "DL"
      params[:doc_state]
    else
      "passportdvs"
    end
  end

end