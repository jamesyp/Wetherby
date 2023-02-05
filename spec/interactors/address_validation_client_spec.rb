# frozen_string_literal: true

require 'rails_helper'

describe AddressValidationClient do
  subject(:result) { described_class.validate(street:, city:, state:) }

  let(:street) { '744 Irving Street' }
  let(:city) { 'San Francisco' }
  let(:state) { 'CA' }

  let(:response) { double(body: file_fixture(response_fixture).read) }
  let(:response_fixture) { 'google_maps/address_response.json' }
  let(:api_key) { Rails.configuration.address_validation_api_key }

  before { allow(HTTParty).to receive(:post).and_return(response) }

  it 'creates and posts a request to Google Maps address validation API' do
    expect(HTTParty).to receive(:post).with(
      'https://addressvalidation.googleapis.com/v1:validateAddress',
      query: { key: api_key },
      headers: { 'Content-Type' => 'application/json' },
      body: {
        address: {
          addressLines: [street],
          administrativeArea: state,
          locality: city
        }
      }.to_json
    )

    subject
  end

  it 'formats the response as a symbol hash' do
    expect(
      subject.dig(:result, :address, :formatted_address)
    ).to eq('744 Irving Street, San Francisco, CA 94122-2410, USA')
  end

  context 'API returns an error' do
    let(:response_fixture) { 'google_maps/error_response.json' }

    it { expect { subject }.to raise_error('address validation API error') }
  end
end
