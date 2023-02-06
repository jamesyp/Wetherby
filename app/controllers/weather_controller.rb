# frozen_string_literal: true

class WeatherController < ApplicationController
  def index
    return if address_params.empty?

    @address, @geo_point = Rails.cache.fetch(address_cache_key) do
      validate_address!.values_at(:standardized_address, :geo_point)
    end

    @forecast = Rails.cache.fetch(
      "forecast/#{@address[:zip_code]}", expires_in: 30.minutes
    ) do
      @not_cached = true
      forecast!
    end
  end

  private

  def validate_address!
    street, city, state = address_params.values_at(:street, :city, :state)
    result = ValidateAndExpandAddress.run(street:, city:, state:)

    unless result.success?
      @error = result.error
      return
    end

    result.value
  end

  def forecast!
    result = GetWeatherForecast.run(**@geo_point)
    unless result.success?
      @error = result.error
      return
    end

    result.value
  end

  def address_params
    params.permit(:street, :city, :state)
  end

  def address_cache_key
    "address/#{address_params.values.join('-').parameterize}"
  end
end
