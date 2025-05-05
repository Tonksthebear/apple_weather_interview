class DailyTemperature < BaseResource
  attribute :min, :float
  attribute :max, :float
  attribute :date, :date

  has_one :forecast

  delegate :daily_temperature_unit, to: :forecast
  alias :temperature_unit :daily_temperature_unit
end
