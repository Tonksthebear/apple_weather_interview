require "test_helper"

class GeocodesFlowTest < ActionDispatch::IntegrationTest
  test "index with valid city name shows results" do
    VCR.use_cassette("find_seattle") do
      get geocodes_path, params: { query: { name: "Seattle" } }
      assert_response :success
      assert_select "a", text: /Seattle/
    end
  end

  test "index with unknown city shows no results" do
    VCR.use_cassette("unknown_city") do
      get geocodes_path, params: { query: { name: "ThisCityDoesNotExist" } }
      assert_response :success
      assert_select "a", text: /ThisCityDoesNotExist/, count: 0
    end
  end

  test "index with no query shows no results" do
    get geocodes_path
    assert_response :success
    assert_select "a", count: 0
  end

  test "show with valid geocode id displays geocode" do
    VCR.use_cassette("find_seattle") do
      VCR.use_cassette("find_seattle_forecast") do
        geocodes = Geocode.where(name: "Seattle")
        geocode = geocodes.first
        get geocode_path(geocode.id)
        assert_response :success
        assert_select "div", text: geocode.name
        assert_select "div", text: geocode.admin1
        assert_select "div", text: geocode.admin2
      end
    end
  end

  test "show with invalid geocode id redirects to index with flash error" do
    VCR.use_cassette("missing_location") do
      get geocode_path(1)
      assert_redirected_to geocodes_path
      follow_redirect!
      assert_select "div", text: "Error viewing location. Please try again."
    end
  end

  test "index with blank query does not raise error and shows no results" do
    get geocodes_path, params: { query: { name: "" } }
    assert_response :success
    assert_select "a", count: 0
  end
end
