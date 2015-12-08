class Wind < ActiveRecord::Base
  belongs_to :datarecord

  def self.get_bom_hash
    latest_time=Datarecord.last.update_time
    bom_hash=Hash.new
    for i in (0..Location.get_location_quantity-1)
      wind_direction=Datarecord.where(update_time: latest_time,record_source:'bom',record_type:'wind').find_by(location_id:i).wind.wind_direction
      wind_speed=Datarecord.where(update_time: latest_time,record_source:'bom',record_type:'wind').find_by(location_id:i).wind.wind_speed

      sub_hash={"wind_direction"=>wind_direction,"wind_speed"=>wind_speed}
      bom_hash.store("#{Location.get_location_hash["#{i}"]["location"]}", sub_hash)
    end

    return bom_hash

  end

  def self.get_api_hash
    latest_time=Datarecord.last.update_time
    api_hash=Hash.new
    for i in (0..Location.get_location_quantity-1)
      wind_direction=Datarecord.where(update_time: latest_time,record_source:'api',record_type:'wind').find_by(location_id:i).wind.wind_direction
      wind_speed=Datarecord.where(update_time: latest_time,record_source:'api',record_type:'wind').find_by(location_id:i).wind.wind_speed
      sub_hash={"wind_direction"=>wind_direction,"wind_speed"=>wind_speed}
      api_hash.store("#{Location.get_location_hash["#{i}"]["location"]}", sub_hash)
    end
    return api_hash
  end

  def self.get_full_hash
    full_hash={"bom"=>self.get_bom_hash,"api"=>self.get_api_hash}
    return full_hash
  end

end