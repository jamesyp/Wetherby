# frozen_string_literal: true

require 'rails_helper'

describe GetZipCode do
  subject(:result) { described_class.run(address:, city:, state_code:) }

  let(:address) { Faker::Address.street_address }
  let(:city) { Faker::Address.city }
  let(:state_code) { Faker::Address.state_abbr }

  let(:expected_value) { Faker::Address.zip_code }
  let(:response_fixture) { 'usps/zip_code_response.xml' }

  before do
    allow(Net::HTTP).to receive(:get).and_return(
      file_fixture(response_fixture).read.gsub('!PLACEHOLDER!', expected_value)
    )
  end

  it 'looks up the zip via USPS API' do
    subject

    expect(Net::HTTP).to have_received(:get).with(
      uri_including('secure.shippingapis.com', address, city, state_code)
    )
  end

  it 'returns a successful result with zip code' do
    expect(result.success?).to eq(true)
    expect(result.value).to eq(expected_value)
    expect(result.error).to be_nil
  end

  context 'API returns an error' do
    let(:response_fixture) { 'usps/zip_code_response_error.xml' }
    let(:expected_value) { Faker::Hipster.sentence }

    it 'returns an error result with description' do
      expect(result.success?).to eq(false)
      expect(result.error).to eq(expected_value)
      expect(result.value).to be_nil
    end
  end
end
