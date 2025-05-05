require "test_helper"

class GeocodeTest < ActiveSupport::TestCase
  test "can search for city" do
    VCR.use_cassette("find_seattle") do
      geocodes = Geocode.where(name: "Seattle")
      assert_not_empty geocodes
      assert geocodes.all? { |g| g.persisted? }
    end
  end

  test "geocodes are automatically associated with forecast and are cached" do
    VCR.use_cassette("find_seattle") do
      VCR.use_cassette("find_seattle_forecast") do
        geocodes = Geocode.where(name: "Seattle")
        geocode = geocodes.first

        Rails.cache.clear
        forecast = geocode.forecast
        assert forecast.cache_missed

        # Unset forecast
        geocode.loaded_relationships[:has_one] = {}

        forecast = geocode.forecast
        assert_not forecast.cache_missed
      end
    end
  end

  test "returns empty array for unknown city" do
    VCR.use_cassette("unknown_city") do
      geocodes = Geocode.where(name: "ThisCityDoesNotExist")
      assert_equal [], geocodes
    end
  end

  test "raises error when searching with blank name" do
    assert_raises(ArgumentError) { Geocode.where(name: "") }
    assert_raises(ArgumentError) { Geocode.where(name: nil) }
  end

  test "can find by id and caches result" do
    VCR.use_cassette("find_seattle") do
      geocodes = Geocode.where(name: "Seattle")
      geocode = geocodes.first

      Rails.cache.clear
      found = Geocode.find(geocode.id)
      assert found.cache_missed

      found_again = Geocode.find(geocode.id)
      assert_not found_again.cache_missed
    end
  end

  test "raises error when finding with blank id" do
    assert_raises(ArgumentError) { Geocode.find(nil) }
    assert_raises(ArgumentError) { Geocode.find("") }
  end

  test "persisted? returns true if id present" do
    geocode = Geocode.new(id: 123)
    assert geocode.persisted?
  end

  test "persisted? returns false if id is nil" do
    geocode = Geocode.new(id: nil)
    assert_not geocode.persisted?
  end
end
