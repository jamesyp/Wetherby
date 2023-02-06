# frozen_string_literal: true

class WeatherController < ApplicationController
  def index
    return if address_params.empty?

    validate_address!
    forecast!
  end

  private

  def validate_address!
    street, city, state = address_params.values_at(:street, :city, :state)

    result = ValidateAndExpandAddress.run(street:, city:, state:)
    unless result.success?
      @error = result.error
      return
    end

    @address = result.value[:standardized_address]
    @geo_point = result.value[:geo_point]
  end

  def forecast!
    result = GetWeatherForecast.run(**@geo_point)
    unless result.success?
      @error = result.error
      return
    end

    @forecast = result.value
  end

  def address_params
    params.permit(:street, :city, :state)
  end
end
