require 'json'

class Prediction < ActiveRecord::Base

	def self.getPredictionByPostcode(postcode,period)
		postcode_url = "https://bitbucket.org/IvanKruchkoff/misc/raw/4738589aa0d9d3477813734db050eaead8476e56/postcodes/postcodes.json"
		# file = File.read('/Users/bragilee/Desktop/postcode.json')
		postcode_hash = Hash.new
		postcode_hash.store(:postcode,postcode)
		postcodes = JSON.parse(open(postcode_url).read)
		lattitudes = []
		longitudes = []
		postcodes.select{ |key| key.to_i>=3000 and key.to_i<=3999}.each do |key,value|
			if(key.to_i == postcode.to_i)
				value.each do |sub_key,sub_value|
					sub_value.each do |i|
						lattitudes << i["geo_lat"].to_f
						longitudes << i["geo_long"].to_f
					end
				end
			end
		end
		if(lattitudes.length==0)
			return "invalid postcode"
		else
			postcode_sub_hash = Prediction.getPredictionByLatLong(lattitudes.sum/lattitudes.length,longitudes.sum/longitudes.length,period)
            postcode_hash.store(:main_predictions, postcode_sub_hash)
            return postcode_hash
        end
    end

	def self.getPredictionByLatLong(lattitude,longitude,period)
		mainHash=Hash.new
		mainHash={:lattitude=>lattitude, :longitude=>longitude}
		p_hash = Hash.new
		nowHash=Hash.new
		preHahs=Hash.new
		
		location=Location.find_by(lattitude:lattitude,longitude:longitude)
		startPoint={:lat=>lattitude,:long=>longitude}
		lastUpdateTime=Observation.last.updateTime
		now=Time.now
		closest=self.getClosesLocation(startPoint)
		closestLocation=closest[:location]
		

		if (((now-lastUpdateTime)<=30*60))
			nowHash={:time=>now}
		else
			lastUpdate=closestLocation.observations.last
			currTemp=lastUpdate.weatherdatum.temperature
			currPrecip=lastUpdate.weatherdatum.precipitation
			currWindDir=lastUpdate.weatherdatum.windDirectionS
			currWindSpe=lastUpdate.weatherdatum.windSpeed
			probablity=getProbablity(closestLocation["distance"],1)
			nowHash={:time=>now,:temperature=>{:value=>currTemp,:probablity=>probablity},
					:rain=>{:value=>currPrecip,:probablity=>probablity},
					:winddirection=>{:value=>currWindDir,:probablity=>probablity},
					:windspeed=>{:value=>currWindSpe,:probablity=>probablity}}
		end
		p_hash.store("0",nowHash)
		# mainHash.store("0",nowHash)

		for i in (1..period.to_i/10)
			
			preData=Observation.getPreData(now,closestLocation.locationID)
			predicTemp=Regression.predictValueProbability(preData[:time],preData[:temp],now,period)
			
			predicPrecip=Regression.predictValueProbability(preData[:time],preData[:precip],now,period)
			predicWindDir=Regression.predictValueProbability(preData[:time],preData[:windDir],now,period)
			predicWindSpe=Regression.predictValueProbability(preData[:time],preData[:windSpe],now,period)
			probTemp=self.getProbablity(closest[:distance],predicTemp[:probablity])
			probPrecip=self.getProbablity(closest[:distance],predicPrecip[:probablity])
			probWindDir=self.getProbablity(closest[:distance],predicWindDir[:probablity])
			probWindSpe=self.getProbablity(closest[:distance],predicWindSpe[:probablity])
			
			predicHash={:time=>"#{now+i*600}",
						:temperature=>{:value=>predicTemp[:predictValue],:probablity=>probTemp},
						:rain=>{:value=>predicPrecip[:predictValue],:probablity=>probPrecip},
						:winddirection=>{:value=>predicWindDir[:predictValue],:probablity=>probWindDir},
						:windspeed=>{:value=>predicWindSpe[:predictValue],:probablity=>probWindSpe}}
			# predicHash={:p=>preData}
			p_hash.store("#{i*10}",predicHash)
			# mainHash.store("#{i*10}",predicHash)
		end
		mainHash.store(:predictions,p_hash)
		return mainHash
	end

	def self.getClosesLocation(startPoint)
		min=Float::INFINITY
		location=Location.new

		Location.all.each do |l|
			endPoint={:lat=>l.lattitude,:long=>l.longitude}
			distance=Prediction.getDisantance(startPoint,endPoint)
			if distance<min
				min=distance
				location=l
			end
		end
		return {:location=>location,:distance=>min}
	end

	def self.getProbablity(distance,probablity)
		return probablity*[1-distance.to_f/60000.0, 0].max.round(2)
	end

	def self.getDisantance(startPoint,endPoint)
		lat1=startPoint[:lat].to_f
		lat2=endPoint[:lat].to_f
		lng1=startPoint[:long].to_f
		lng2=endPoint[:long].to_f
		lat_diff = (lat1 - lat2)*Math::PI/180.0  
		lng_diff = (lng1 - lng2)*Math::PI/180.0  
		lat_sin = Math.sin(lat_diff/2.0) ** 2  
		lng_sin = Math.sin(lng_diff/2.0) ** 2  
		first = Math.sqrt(lat_sin + Math.cos(lat1*Math::PI/180.0) * Math.cos(lat2*Math::PI/180.0) * lng_sin)  
		result = Math.asin(first) * 2 * 6378137.0  
		return result.to_i
		# return 1
	end

end
