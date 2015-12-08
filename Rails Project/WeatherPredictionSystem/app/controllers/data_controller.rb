class DataController < ApplicationController
  def showLocation
  	@location_data = Location.getDataByLocation(params[:location_id],params[:date])
  end

  def showPostcode
  	@postcode_data = Location.getDataByPostcode(params[:postcode],params[:date])
  end
end
