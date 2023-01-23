# frozen_string_literal: true

require 'net/http'

class GetZipCode
  def self.run(address:, city:, state_code:)
    new(address, city, state_code).run
  end

  def run
    OpenStruct.new(
      success?: error.blank?,
      error: error,
      value: value
    )
  end

  protected

  def initialize(address, city, state_code)
    @address = address
    @city = city
    @state_code = state_code
  end

  private

  def value
    @value ||= Nokogiri::XML(api_response).xpath('//Zip5').inner_text.presence
  end

  def error
    @error ||= Nokogiri::XML(api_response).xpath('//Error//Description').inner_text.presence
  end

  # https://www.usps.com/business/web-tools-apis/address-information-api.htm#_Toc110511817
  def api_response
    @api_response ||= Net::HTTP.get(
      URI::HTTPS.build(
        host: 'secure.shippingapis.com',
        path: '/ShippingAPI.dll',
        query: {
          API: 'ZipCodeLookup',
          XML: query_xml
        }.to_query
      )
    )
  end

  def query_xml
    user_id = Rails.application.credentials.dig(:usps, :user_id)

    <<~XML
      <ZipCodeLookupRequest USERID="#{user_id}">
        <Address ID="1">
          <Address2>#{@address}</Address2>
          <City>#{@city}</City>
          <State>#{@state_code}</State>
        </Address>
      </ZipCodeLookupRequest>
    XML
  end
end
