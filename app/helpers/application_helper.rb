module ApplicationHelper
  def daily_temperature_max_bar_height(daily_temperature)
    min_temperature = daily_temperature.forecast.starting_max_temperature
    max_temperature = daily_temperature.forecast.ending_max_temperature

    # We're styling the bar to be h-50 so we'll calculate the height as a percentage of that
    # while we keep an absolute min of 10 so that we can display the text
    temperature_height_ratio = (max_temperature - min_temperature) / 50
    base_temperature = min_temperature * temperature_height_ratio
    daily_temperature.max * temperature_height_ratio - base_temperature + 10
  end

  def daily_temperature_min_bar_height(daily_temperature)
    max_temperature = daily_temperature.forecast.ending_min_temperature
    min_temperature = daily_temperature.forecast.starting_min_temperature

    # We're styling the bar to be h-50 so we'll calculate the height as a percentage of that
    # while we keep an absolute min of 10 so that we can display the text
    temperature_height_ratio = (min_temperature - max_temperature) / 50
    base_temperature = max_temperature * temperature_height_ratio
    daily_temperature.min * temperature_height_ratio - base_temperature + 10
  end
end
