require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

class Location < ActiveRecord::Base
	has_many :observations

  def self.update
    url = 'http://www.bom.gov.au/vic/observations/vicall.shtml'

    doc = Nokogiri::HTML(open(url))
    content = doc.css('tbody .rowleftcolumn')
    location_name = []
    location_lon = []
    location_lat = []
    location_coor = []
    location_hash = Hash.new
    i = 0
    content.css('th').each do |site|
      location_name << site.text
      name = site.text
      sub_hash = Hash.new
      site_link = site.css('a')[0]['href']
      site_url = "http://www.bom.gov.au/#{site_link}"
      site_doc = Nokogiri::HTML(open(site_url))
      site_content = site_doc.css('.stationdetails').css('tr').css('td')
      location_lat[i] = (site_content[3].text[/[0-9.-]+/])
      location_lon[i] = (site_content[4].text[/[0-9.-]+/])

      location_coor[i] = location_lat[i] + "," + location_lon[i]
      sub_hash["coordinate"] = location_coor[i]
      location_info = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?latlng=#{location_coor[i]}&sensor=true_or_false").read)
      sub_array = location_info["results"][0]["address_components"]

      sub_array.each do |sub|
        if (sub["types"] == ["postal_code"])
          sub_hash["postcode"] = sub["long_name"]
          sub_hash["lattitude"] = location_lat[i]
          sub_hash["longitude"] = location_lon[i]
          location_hash[name] = sub_hash
        end
      end
      i = i+1
    end
    location_hash.each do |key,value|
      Location.create(:locationID=> key, :lattitude=>value["lattitude"].to_f, :longitude=>value["longitude"].to_f, :postcode=>value["postcode"].to_i)
    end
  end


  # The 1st API
  def self.getLocations
    h = Hash.new
    d = Date.today
    h.store("date",d)
    location_array = []
    locations = Location.all
    locations.each do |l|
      sub_hash = Hash.new
      t = Observation.where(location_id: l.id).last.updateTime
      sub_hash = {"id"=>l.locationID, "lat"=>l.lattitude, "lon"=>l.longitude, "last_update"=>t.to_time}
      location_array << sub_hash
    end
    h.store("locations", location_array)
    return h
  end

  # The 2nd API
  def self.getDataByLocation(locationID, date)
    h = Hash.new
    date = date.to_date
    h.store("date",date)
    location = Location.find_by(locationID:locationID)
    if(location==nil)
      h.store("measurements", [])
      return h
    else
      temp = Observation.getCurrTemp(location.id)
      h.store("current_temp",temp)
      cond = Observation.getCurrCond(location.id)
      h.store("current_cond",cond)
      m_array = Observation.getMeasurements(location.id, date)
      h.store("measurements", m_array)
      return h
    end
  end

   # The 3rd API
  def self.getDataByPostcode(postcode, date)
    date = date.to_date
    h = Hash.new
    h.store("date",date)
    locations = Location.where(postcode:postcode)
    if(locations == nil)
      h.store("locations", [])
    else
      location_array = []
      locations.each do |l|
        sub_hash = Hash.new
        t = Observation.where(location_id: l.id).last.updateTime
        m_array = Observation.getMeasurements(l.id, date)
        sub_hash = {"id"=>l.locationID, "lat"=>l.lattitude, "lon"=>l.longitude, "last_update"=>t.to_time, "measurements"=>m_array}
        location_array << sub_hash
      end
      h.store("locations", location_array)
    end
    return h
  end
end
