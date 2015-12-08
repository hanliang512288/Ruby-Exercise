class Weatherdatum < ActiveRecord::Base
	belongs_to :observation
	
	def self.windDirectionToString windBearing
		case windBearing
	      when 0
	        'N'
	      when 0.01..44.99
	        'NNE'
	      when 45
	        'NE'
	      when 45.01..89.99
	        'ENE'
	      when 90
	        'E'
	      when 90.01..134.99
	        'ESE'
	      when 135
	        'SE'
	      when 135.01..179.99
	        'SSE'
	      when 180
	        'S'
	      when 180.01..224.99
	        'SSW'
	      when 225
	        'SW'
	      when 225.01..269.99
	        'WSW'
	      when 270
	        'W'
	      when 270.01..314.99
	        'WNW'
	      when 315
	        'NW'
	      when 315.01..359.99
	        'NNW'
	      else
	        'N/A'
	    end
	end

end
