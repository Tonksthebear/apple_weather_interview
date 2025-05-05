class GeocodesController < ApplicationController
  def index
    @name = geocode_search_params[:name] if params[:query]
    @geocodes = @name.present? ? Geocode.where(name: @name) : []
  end

  def show
    @geocode = Geocode.find(params[:id])
  rescue StandardError
    redirect_to geocodes_path, alert: "Error viewing location. Please try again."
  end

  private

  def geocode_search_params
    params.fetch(:query).permit(:name).to_h.symbolize_keys
  end
end
