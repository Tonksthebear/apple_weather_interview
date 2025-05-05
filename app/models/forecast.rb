class Forecast < BaseResource
  attribute :latitude, :float
  attribute :longitude, :float
  attribute :generationtime_ms, :float
  attribute :utc_offset_seconds, :integer
  attribute :timezone, :string
  attribute :timezone_abbreviation, :string
  attribute :elevation, :float
  attribute :current_units, default: {}
  attribute :current, default: {}
  attribute :daily, default: {}
  attribute :daily_units, default: {}
  attribute :cache_missed, :boolean

  belongs_to :geocode
  has_many :daily_temperatures

  # For the style we want to display, we want the largest min temperature
  def starting_min_temperature
    daily_temperatures.collect(&:min).max
  end

  def ending_min_temperature
    daily_temperatures.collect(&:min).min
  end

  # For the style we want to display, we want the smallest max temperature
  def starting_max_temperature
    daily_temperatures.collect(&:max).min
  end

  def ending_max_temperature
    daily_temperatures.collect(&:max).max
  end


  def daily=(temperature_hash)
    self.daily_temperatures = temperature_hash["time"].map.with_index do |date, index|
      DailyTemperature.new(
        date: date,
        min: temperature_hash["temperature_2m_min"][index],
        max: temperature_hash["temperature_2m_max"][index],
        forecast: self
      )
    end
  end

  def daily_temperature_unit
    daily_units["temperature_2m_max"]
  end

  class << self
    def find_by(latitude:, longitude:, forecast_days: 7, temperature_unit: "fahrenheit", **kwargs)
      raise ArgumentError, "Latitude and Longitude cannot be blank" if latitude.blank? || longitude.blank?
      composite_cache_key = "#{latitude}/#{longitude}/#{forecast_days}/#{temperature_unit}/#{kwargs}"

      cache_missed = false

      # We want to be sure the cache key is unique to the parameters
      forecast = Rails.cache.fetch(composite_cache_key, expires_in: 30.minutes) do
        cache_missed = true
        get("forecast", latitude:, longitude:, forecast_days:, temperature_unit:, models: "gfs_seamless", current: "temperature_2m", daily: "temperature_2m_max,temperature_2m_min", **kwargs)
      end

      forecast.cache_missed = cache_missed
      forecast
    end
  end
end
