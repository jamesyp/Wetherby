# frozen_string_literal: true

class GetWeatherForecast < BaseInteractor
  protected

  REQUEST_HEADERS = {
    'User-Agent' => 'Wetherby backend, contact: jamesyp@gmail.com'
  }.freeze

  def initialize(latitude:, longitude:)
    @latitude = latitude
    @longitude = longitude
  end

  private

  def result
    forecast_data.dig(:properties, :periods)
  end

  def forecast_endpoint
    point_data.dig(:properties, :forecast)
  end

  def point_endpoint
    "https://api.weather.gov/points/#{@latitude},#{@longitude}"
  end

  def forecast_data
    @forecast_data ||= JSON.parse(
      HTTParty.get(forecast_endpoint, headers: REQUEST_HEADERS).body
    ).deep_transform_keys(&:underscore).deep_symbolize_keys
  end

  def point_data
    @point_data ||= begin
      response = HTTParty.get(point_endpoint, headers: REQUEST_HEADERS)
      ok = response.ok?
      json = JSON.parse(response.body).with_indifferent_access
      raise StandardError, json[:detail] unless ok

      json
    end
  end
end
