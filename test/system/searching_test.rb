require "application_system_test_case"

class SearchingTest < ApplicationSystemTestCase
  test "only shows results if they are present" do
    VCR.use_cassette("find_seattle") do
      VCR.use_cassette("unknown_city") do
        visit geocodes_path
        find("#query_name").set "Seattle"
        find("button[type='submit']").click
        assert_text "Select a location to view the forecast"
        assert_no_text "No locations found"

        find("#query_name").set "ThisCityDoesNotExist"
        find("button[type='submit']").click
        assert_no_text "Select a location to view the forecast"
        assert_text "No locations found"
      end
    end
  end
end
