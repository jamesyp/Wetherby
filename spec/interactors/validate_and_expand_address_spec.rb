# frozen_string_literal: true

require 'rails_helper'

describe ValidateAndExpandAddress do
  subject(:result) { described_class.run(street:, city:, state:) }

  let(:street) { '744 Irving Street' }
  let(:city) { 'San Francisco' }
  let(:state) { 'CA' }

  let(:response_json) { file_fixture('google_maps/address_response.json').read }
  let(:validation_response) { JSON.parse(response_json).deep_transform_keys(&:underscore).deep_symbolize_keys }

  let(:standardized_address) { validation_response.dig(:result, :usps_data, :standardized_address) }
  let(:geo_point) { validation_response.dig(:result, :geocode, :location) }

  before { allow(AddressValidationClient).to receive(:validate).and_return(validation_response) }

  it 'looks up address information with Google Maps address validation API' do
    expect(AddressValidationClient).to receive(:validate).with(street:, city:, state:)

    subject
  end

  it 'returns a processed result' do
    aggregate_failures do
      expect(result.success?).to eq(true)
      expect(result.result).to eq(
        {
          standardized_address:,
          geo_point:
        }
      )
      expect(result.error).to be_nil
    end
  end

  context 'API returns an error' do
    let(:expected_error) { Faker::Hipster.sentence }

    before { allow(AddressValidationClient).to receive(:validate).and_raise(StandardError.new(expected_error)) }

    it 'returns an error result with description' do
      expect(result.success?).to eq(false)
      expect(result.error).to eq(expected_error)
      expect(result.result).to be_nil
    end
  end
end
