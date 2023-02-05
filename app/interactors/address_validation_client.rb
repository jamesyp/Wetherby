# frozen_string_literal: true

require 'net/http'

class AddressValidationClient
  def self.validate(street:, city:, state:)
    new(street, city, state).response
  end

  # https://developers.google.com/maps/documentation/address-validation/requests-validate-address
  def response
    http_response = HTTParty.post(
      'https://addressvalidation.googleapis.com/v1:validateAddress',
      query: { key: Rails.configuration.address_validation_api_key },
      headers: { 'Content-Type' => 'application/json' },
      body: request_body.to_json
    )

    response_json = JSON.parse(http_response.body)
    raise StandardError, 'address validation API error' if response_json['error']

    response_json.deep_transform_keys(&:underscore).deep_symbolize_keys
  end

  protected

  def initialize(street, city, state)
    @street = street
    @city = city
    @state = state
  end

  private

  def request_body
    {
      address: {
        addressLines: [@street],
        administrativeArea: @state,
        locality: @city
      }
    }
  end
end
