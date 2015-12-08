class Rain < ActiveRecord::Base
  belongs_to :datarecord

  def self.get_bom_hash
    latest_time=Datarecord.last.update_time
    bom_hash=Hash.new
    for i in (0..Location.get_location_quantity-1)
      rain_fall=Datarecord.where(update_time: latest_time,record_source:'bom',record_type:'rain').find_by(location_id:i).rain.rain_fall
      sub_hash={"rain_fall"=>rain_fall}
      bom_hash.store("#{Location.get_location_hash["#{i}"]["location"]}", sub_hash)
    end

    return bom_hash

  end

  def self.get_api_hash
    latest_time=Datarecord.last.update_time
    bom_hash=Hash.new
    for i in (0..Location.get_location_quantity-1)
      rain_fall=Datarecord.where(update_time: latest_time,record_source:'api',record_type:'rain').find_by(location_id:i).rain.rain_fall
      sub_hash={"rain_fall"=>rain_fall}
      bom_hash.store("#{Location.get_location_hash["#{i}"]["location"]}", sub_hash)
    end
    return bom_hash
  end

  def self.get_full_hash
    full_hash={"bom"=>self.get_bom_hash,"api"=>self.get_api_hash}
    return full_hash
  end

end
