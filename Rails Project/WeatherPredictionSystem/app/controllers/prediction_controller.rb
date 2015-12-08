class PredictionController < ApplicationController
  def showLatLong
	@prediction_lat_lon = Prediction.getPredictionByLatLong(params[:lat],params[:long],params[:period])
  end

  def showPostcode
  	@prediction_postcode = Prediction.getPredictionByPostcode(params[:postcode],params[:period])
  end
end
