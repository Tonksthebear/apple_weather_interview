require "test_helper"

class ForecastTest < ActiveSupport::TestCase
  test "raises error when latitude or longitude is blank" do
    assert_raises(ArgumentError) { Forecast.find_by(latitude: nil, longitude: -122.3321) }
    assert_raises(ArgumentError) { Forecast.find_by(latitude: 47.6062, longitude: nil) }
    assert_raises(ArgumentError) { Forecast.find_by(latitude: nil, longitude: nil) }
  end

  test "parses daily temperatures and units correctly" do
    VCR.use_cassette("find_seattle") do
      VCR.use_cassette("find_seattle_forecast") do
        forecast = Geocode.where(name: "Seattle").first.forecast
        assert forecast.daily_temperatures.any?, "Should have daily temperatures"
        assert_kind_of DailyTemperature, forecast.daily_temperatures.first
        assert forecast.daily_temperature_unit.present?
      end
    end
  end

  test "starting and ending min/max temperature methods work" do
    VCR.use_cassette("find_seattle") do
      VCR.use_cassette("find_seattle_forecast") do
        forecast = Geocode.where(name: "Seattle").first.forecast
        mins = forecast.daily_temperatures.map(&:min)
        maxs = forecast.daily_temperatures.map(&:max)
        assert_equal mins.max, forecast.starting_min_temperature
        assert_equal mins.min, forecast.ending_min_temperature
        assert_equal maxs.min, forecast.starting_max_temperature
        assert_equal maxs.max, forecast.ending_max_temperature
      end
    end
  end
end
