# frozen_string_literal: true

module WeatherHelper
  def formatted_address(address)
    street, city, state, zip_code = address.values_at(:first_address_line, :city, :state, :zip_code)
    "#{street.titleize}, #{city.titleize} #{state.upcase} #{zip_code}"
  end

  def formatted_time(iso8601_string)
    DateTime.parse(iso8601_string).strftime('%a %b %d,%l%p')
  end

  def temperature_indicator(trend)
    return '⬆️' if trend == 'rising'
    return '⬇️' if trend == 'falling'
  end
end
