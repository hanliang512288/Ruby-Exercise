require 'nokogiri'
require 'open-uri'

class Location < ActiveRecord::Base
  has_many :datarecords

  def self.update
  url = 'http://www.bom.gov.au/vic/observations/melbourne.shtml'
  doc = Nokogiri::HTML(open(url))
  table = doc.css('a').select do |row|
    ((row['href']=~/\/products/)!=nil) && ((row['title']=~//)==nil)
  end
  index='http://www.bom.gov.au/'
  urls=table.map{|add| index+add['href']}
  latitude=[]
  longitude=[]
  name=[]
  urls.each do |add|
    page_doc=Nokogiri::HTML(open(add))
    latitude<</-[0-9]{2}.[0-9]{2}/.match(page_doc.css('table[class=stationdetails]').css('td')[3].text).to_s.to_f
    longitude<</[0-9]{3}.[0-9]+/.match(page_doc.css('table[class=stationdetails]').css('td')[4]).to_s.to_f
    name<<page_doc.css('table[class=stationdetails]').css('td')[2].text.split(/:\s/)[1].to_s
  end
  for i in (0..name.length-1)
    Location.create(:id=>i, :location_name=>name[i], :latitude =>latitude[i], :longitude=>longitude[i])
  end
  end

  def self.get_location_quantity
    return Location.all.count
  end

  def self.get_location_hash
    location_hash=Hash.new
    Location.all.each do |location|
      sub_hash={"location"=>"#{location.location_name}", "latitude"=>location.latitude,"longitude"=>location.longitude}
      location_hash.store("#{location.id}",sub_hash)
    end
    return location_hash
  end

end

