require 'date'
class LocationController < ApplicationController
  def showLocations
   	@locations = Location.getLocations
   	@date = Date.today
  end
end
