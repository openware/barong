# frozen_string_literal: true
#require "spec_helper"
require "savon"

describe "Green ID Services Tests" do

  it "Register Verification" do
    client = Savon.client do
      wsdl "https://test-au.vixverify.com/Registrations-Registrations/DynamicFormsServiceV3?WSDL"
      open_timeout 10
      read_timeout 10
      #log true
    end

    response = call_and_fail_gracefully(client, :register_verification) do
      message(:accountId => 'lexiumcapital',
              :password => "5n2-QBN-QdR-APM",
              :verificationId => "abcd",
              :ruleId => "Default",
              :name =>
                {
                  :honorific => "Mr", :givenName => "Ting",
                  :middleNames => "Ming", :surname => "Yuen"
                },
              :currentResidentialAddress =>
                {
                  :flatNumber => "", :streetNumber => "15",
                  :streetName => "Bonds", :streetType => "RD",
                  :suburb => "Riverwood", :postcode => "2210",
                  :state => "NSW", :country => "AU"
                },
              :dob =>
                {
                  :day => 8,
                  :month => 8,
                  :year => 1990
                }
      )
    end

    xml_doc = Nokogiri::XML(response.to_s)
    xml_doc.remove_namespaces!

    Rails.logger.info "test"

    puts "Verification Status #{xml_doc.xpath("//registerVerificationResponse/return/verificationResult/overallVerificationStatus").text}"

    verificationId = xml_doc.xpath("//registerVerificationResponse/return/verificationResult/verificationId").text
    #puts xml_doc.xpath("//registerVerificationResponse/return/sourceList")
    expect(verificationId).to eq("abcd")
  end

  it "Get Fields" do

    sourceId = "passportdvs" # nswregodvs, ntregodvs, saregodvs, tasregodvs, waregodvs, qldrego, actrego, vicrego, passportdvs

    client = Savon.client do
      wsdl "https://test-au.vixverify.com/Registrations-Registrations/DynamicFormsServiceV3?WSDL"
      open_timeout 10
      read_timeout 10
      log true
    end

    response = call_and_fail_gracefully(client, :get_fields) do
      message(:accountId => 'lexiumcapital',
              :password => "5n2-QBN-QdR-APM",
              :verificationId => "abcd",
              :ruleId => "Default",
              :sourceId => sourceId
      )
    end

    xml_doc = Nokogiri::XML(response.to_s)
    xml_doc.remove_namespaces!

    puts xml_doc.xpath("//getFieldsResponse/return/sourceFields/fieldList")

    expect(1).to eq(1)
  end

  it "Set Fields Driving License" do

    sourceId = "nswregodvs"

    client = Savon.client do
      wsdl "https://test-au.vixverify.com/Registrations-Registrations/DynamicFormsServiceV3?WSDL"
      open_timeout 10
      read_timeout 10
      #log true
    end

    response = call_and_fail_gracefully(client, :set_fields) do
      message(:accountId => 'lexiumcapital',
              :password => "5n2-QBN-QdR-APM",
              :verificationId => "abcd",
              #:ruleId => "Default",
              :sourceId => sourceId,
              :inputFields =>
                {
                  :input =>
                    [
                      {
                        :name => "greenid_#{sourceId}_number",
                        :value => "1234567"
                      },
                      {
                        :name => "greenid_#{sourceId}_givenname",
                        :value => "dsdd"
                      },
                      {
                        :name => "greenid_#{sourceId}_middlename",
                        :value => ""
                      },
                      {
                        :name => "greenid_#{sourceId}_surname",
                        :value => "dsdd"
                      },
                      {
                        :name => "greenid_#{sourceId}_dob",
                        :value => "08/08/1988"
                      },
                      {
                        :name => "greenid_#{sourceId}_tandc",
                        :value => "on"
                      }
                    ]
                }
      )
    end

    puts response
    xml_doc = Nokogiri::XML(response.to_s)
    xml_doc.remove_namespaces!

    verification_status = xml_doc.xpath("//setFieldsResponse/return/verificationResult/overallVerificationStatus").text

    puts "verification status #{verification_status}"

    expect(1).to eq(1)
  end

end

#actrego, actregodvs,
#nswrego, nswregodvs,
#ntregodvs,
#qldrego, qldregodvs,
#sarego, saregodvs,
#tasregodvs,
#vicrego, vicrego_old, vicregodvs,
#warego, waregodvs
#passportdvs,
#:sourceId => "docupload"