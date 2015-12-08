require 'json'
require 'date'
require 'open-uri'

class Observation < ActiveRecord::Base
	belongs_to :location
	has_one :weatherdatum

	def self.updateAll
		
		if(Location.all.length == 0)
     		Location.update
  		end
	
  		locations = Location.all
    	update_d  = Date.today
    	update_t = Time.now

    	locations.each do |i|
      		Observation.create(:location_id=>i.id, :updateDate=>update_d, :updateTime=>update_t)
    	end


		api_key = ['44bd7e76c16db9f1fa02d8abefd8a91a','eb8260b250e340859f5b01c4595131d6','909b3600b94a4324f3b1da8556095bac','2c77f503e4db910c0f69da1a5fc469a5','04906a88537e3862e2ac7c67bf9a223a']
    	base_url = 'https://api.forecast.io/forecast'

    	locations.each do |l|
      		lat_long="#{l.lattitude},#{l.longitude}"
      		forecast = JSON.parse(open("#{base_url}/#{api_key[l.id%5]}/#{lat_long}?units=ca").read)
      		temp = forecast["currently"]["temperature"].to_f
     		cond = forecast["currently"]["summary"]
      		ws = forecast["currently"]["windSpeed"].to_f
      		wdd = forecast["currently"]["windBearing"].to_f
      		wds = Weatherdatum.windDirectionToString(forecast["currently"]["windBearing"])
      		precip = forecast["currently"]["precipIntensity"].to_f
      		loc_id=l.id
      		obid=self.where(location_id:loc_id).last.id
      		Weatherdatum.create(:temperature=>temp,:precipitation=>precip,:windSpeed=>ws,:windDirectionD=>wdd,:windDirectionS=>wds,:condition=>cond,:observation_id=>obid)
      	end
	end

 	def self.getCurrTemp(location_id)
		t = Observation.where(location_id: location_id).last.updateTime
		
		if((Time.now-t)<30*60)
			temp_id = Observation.find_by(location_id: location_id, updatetime: t).id
			temp = Weatherdatum.find_by(observation_id:temp_id).temperature
		else
		    temp = nil
		end
		return temp
	end

  	def self.getMeasurements(location_id, date)
	    date = date.to_date
	    h = Hash.new
	    records_t = self.where(location_id: location_id, updateDate: date)

	    time_arrary = []
	    temp_arrary = []
	    precip_arrary = []
		wind_spe_array = []
		wind_dir_array=[]

	    records_t.each do |r|
	      time_arrary << r.updateTime
	      temp_arrary << r.weatherdatum.temperature
	      precip_arrary << r.weatherdatum.precipitation
	      wind_spe_array << r.weatherdatum.windSpeed
	      wind_dir_array << r.weatherdatum.windDirectionS
	    end

	    m_array = []
	    (0..(time_arrary.length-1)).each do |i|
	      sh = Hash.new
	      sh = {"time" => time_arrary[i].to_time, "temp" => temp_arrary[i], "precip" => precip_arrary[i], "wind_direction" => wind_dir_array[i], "wind_speed" => wind_spe_array[i] }
	      m_array << sh
	    end

	    return m_array
  	end

  	def self.getCurrCond(location_id)
	    t = Observation.where(location_id: location_id).last.updateTime
	    return Observation.find_by(location_id: location_id, updateTime: t).weatherdatum.condition
	end

	def self.getPreData(now,locationID)
		start=now-24*60*60
		observations=Location.find_by(locationID:locationID).observations.where("updateTime >=:s AND updateTime<:n",{s:start,n:now})
		
		preData=Hash.new

		time_arrary=[]
		temp_arrary=[]
		wind_spe_array=[]
		wind_dir_array=[]
		precip_arrary=[]
		
		observations.each do |o|
			time_arrary<<o.updateTime.to_i
			temp_arrary<<o.weatherdatum.temperature
			wind_spe_array<<o.weatherdatum.windSpeed
			wind_dir_array<<o.weatherdatum.windDirectionD
			precip_arrary<<o.weatherdatum.precipitation
		end

		return preData={:time=>time_arrary,:temp=>temp_arrary,:windSpe=>wind_spe_array,:windDir=>wind_dir_array,:precip=>precip_arrary}
	end


end
