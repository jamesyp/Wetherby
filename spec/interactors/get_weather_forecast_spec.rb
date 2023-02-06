# frozen_string_literal: true

require 'rails_helper'

describe GetWeatherForecast do
  subject(:result) { described_class.run(latitude:, longitude:) }

  let(:latitude) { 37.7642911 }
  let(:longitude) { -122.4660297 }

  let(:request_headers) { { 'User-Agent' => 'Wetherby backend, contact: jamesyp@gmail.com' } }

  let(:point_endpoint) { "https://api.weather.gov/points/#{latitude},#{longitude}" }
  let(:point_response_fixture) { 'weather_gov/point_response.json' }
  let(:point_response) { double(body: file_fixture(point_response_fixture).read, ok?: point_response_ok) }
  let(:point_response_ok) { true }

  let(:forecast_endpoint) { JSON.parse(point_response.body).dig('properties', 'forecast') }
  let(:forecast_response_fixture) { 'weather_gov/forecast_response.json' }
  let(:forecast_response) { double(body: file_fixture(forecast_response_fixture).read) }

  let(:expected_forecast) do
    JSON.parse(forecast_response.body).deep_transform_keys(&:underscore).deep_symbolize_keys.dig(:properties, :periods)
  end

  before do
    allow(HTTParty).to receive(:get).with(point_endpoint, anything).and_return(point_response)
    allow(HTTParty).to receive(:get).with(forecast_endpoint, anything).and_return(forecast_response)
  end

  it 'gets geopoint and forecast data using the National Weather Service API' do
    expect(HTTParty).to receive(:get).with(
      "https://api.weather.gov/points/#{latitude},#{longitude}",
      headers: request_headers
    )
    expect(HTTParty).to receive(:get).with(
      forecast_endpoint,
      headers: request_headers
    )

    subject
  end

  it 'returns an array of forecast periods' do
    expect(subject.value).to eq(expected_forecast)
  end

  context 'API returns an error' do
    let(:point_response_fixture) { 'weather_gov/point_error_response.json' }
    let(:point_response_ok) { false }

    it do
      expect(subject.success?).to eq(false)
      expect(subject.value).to be_nil
      expect(subject.error).to eq("Parameter \"point\" is invalid: '1000,1000' does not appear to be a valid coordinate")
    end
  end
end
