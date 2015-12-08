
class WeatherdataController < ApplicationController
  def index
    @location_hash=Location.get_location_hash
    @bom_temp=Temperature.get_bom_hash
    @api_temp=Temperature.get_api_hash
    @bom_wind=Wind.get_bom_hash
    @bom_rain=Rain.get_bom_hash
    @api_rain=Rain.get_api_hash
    @api_wind=Wind.get_api_hash
  end
end

