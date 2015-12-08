require 'nokogiri'
require 'open-uri'
require 'json'

class Datarecord < ActiveRecord::Base
  belongs_to :location
  has_one :rain
  has_one :temperature
  has_one :wind

  def self.update_all

      Location.delete_all
      Location.update


    update_time=Time.new

    for i in (0..Location.get_location_quantity-1)
      self.create(:location_id=>i, :record_source=>"bom", :record_type=>"tem",:update_time=>update_time)
      self.create(:location_id=>i, :record_source=>"bom", :record_type=>"rain",:update_time=>update_time)
      self.create(:location_id=>i, :record_source=>"bom", :record_type=>"wind",:update_time=>update_time)
      self.create(:location_id=>i, :record_source=>"api", :record_type=>"tem",:update_time=>update_time)
      self.create(:location_id=>i, :record_source=>"api", :record_type=>"wind",:update_time=>update_time)
      self.create(:location_id=>i, :record_source=>"api", :record_type=>"rain",:update_time=>update_time)
    end

    self.bom_update
    self.api_update

  end

  def self.bom_update
    url = 'http://www.bom.gov.au/vic/observations/melbourne.shtml'
    doc = Nokogiri::HTML(open(url))
    bom_tem = doc.css('tr').css('td').select {|row| row['headers']=~/obs-temp/}.map{|record| (record.text)=='-'?nil:record.text.to_f}
    bom_rain = doc.css('tr').css('td').select {|row| row['headers']=~/obs-rainsince9am/}.map{|record| (record.text)=='-'?nil:record.text.to_f}
    bom_dew_point= doc.css('tr').css('td').select {|row| row['headers']=~/obs-dewpoint/}.map{|record| (record.text)=='-'?nil:record.text.to_f}
    bom_wind_dir=doc.css('tr').css('td').select {|row| row['headers']=~/obs-wind obs-wind-dir/}.map do|record|
      case record.text
        when "N"
          0
        when "NNE"
          22.5
        when "NE"
          45
        when "ENE"
          67.5
        when "E"
          90
        when "ESE"
          112.5
        when "SE"
          135
        when "SSE"
          157.5
        when "S"
          180
        when "SSW"
          202.5
        when "SW"
          225
        when "WSW"
          247.5
        when "w"
          270
        when "WNW"
          292.5
        when "NW"
          315
        when "NNW"
          337.5
        else
          nil
      end
    end
    bom_wind_speed=doc.css('tr').css('td').select {|row| row['headers']=~/obs-wind obs-wind-spd-kph/}.map{|record| record.text.to_i}


    for i in (0..bom_tem.length-1)
      latest_time=self.last.update_time
      temID=self.find_by(update_time: latest_time,location_id: i,record_source:'bom',record_type:'tem').id
      Temperature.create(:datarecord_id=> temID,:curr_temp=>bom_tem[i],:dew_point=>bom_dew_point[i])
      rainID=self.find_by(update_time: latest_time,location_id: i,record_source:'bom',record_type:'rain').id
      Rain.create(:datarecord_id=> rainID,:rain_fall=>bom_rain[i])
      windID=self.find_by(update_time: latest_time,location_id: i,record_source:'bom',record_type:'wind').id
      Wind.create(:datarecord_id=> windID,:wind_speed=>bom_wind_speed[i],:wind_direction=>bom_wind_dir[i])
    end

  end

  def self.api_update
    api_key = 'eb8260b250e340859f5b01c4595131d6'
    base_url = 'https://api.forecast.io/forecast'
    lat=Location.all.map{|record| record.latitude}
    long=Location.all.map{|record| record.longitude}

    for i in (0..lat.length-1)
      latest_time=self.last.update_time
      lat_long="#{lat[i]},#{long[i]}"
      record_json = JSON.parse(open("#{base_url}/#{api_key}/#{lat_long}?units=ca").read)

      api_tem=record_json["currently"]["temperature"].to_f
      api_dew_point=record_json["currently"]["dewPoint"].to_f
      api_wind_speed=record_json["currently"]["windSpeed"].to_f

      api_wind_dir=record_json["currently"]["windBearing"].to_f
      api_ave_rain=record_json["daily"]["precipIntensity"].to_f
      hour=Time.at(record_json["currently"]["time"].to_i).hour
      if hour>9
        api_rain=(hour-9)*api_ave_rain
      else
        api_rain=(hour+15)*api_ave_rain
      end


      temID=self.find_by(update_time: latest_time, location_id: i,record_source:'api',record_type:'tem').id
      Temperature.create(:datarecord_id=> temID,:curr_temp=>api_tem,:dew_point=>api_dew_point)
      windID=self.find_by(update_time: latest_time, location_id: i,record_source:'api',record_type:'wind').id
      Wind.create(:datarecord_id=> windID,:wind_speed=>api_wind_speed,:wind_direction=>api_wind_dir)
      rainID=self.find_by(update_time: latest_time, location_id: i,record_source:'api',record_type:'rain').id
      Rain.create(:datarecord_id=> rainID,:rain_fall=>api_rain)
    end

  end

  def self.get_full_record
    return {"Temperature"=>Temperature.get_full_hash, "Wind"=>Wind.get_full_hash, "Rain"=>Rain.get_full_hash}
  end

end
