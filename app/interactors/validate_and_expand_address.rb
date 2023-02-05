# frozen_string_literal: true

class ValidateAndExpandAddress < BaseInteractor
  protected

  def initialize(street:, city:, state:)
    @street = street
    @city = city
    @state = state
  end

  private

  def value
    validated_address
    return if error

    {
      standardized_address: validated_address.dig(:usps_data, :standardized_address),
      geo_point: validated_address.dig(:geocode, :location)
    }
  end

  def validated_address
    @validated_address ||= AddressValidationClient.validate(street: @street, city: @city, state: @state)[:result]
  rescue StandardError => e
    @error = e.message
    @validated_address = {}
  end

  def request_body
    {
      address: {
        addressLines: [@street],
        administrativeArea: @state,
        locality: @city
      }
    }.to_json
  end
end
