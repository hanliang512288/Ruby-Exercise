class Temperature < ActiveRecord::Base
  belongs_to :datarecord

  def self.get_api_hash
    latest_time=Datarecord.last.update_time
    api_hash=Hash.new
    for i in (0..Location.get_location_quantity-1)
      temp=Datarecord.where(update_time: latest_time,record_source:'api',record_type:'tem').find_by(location_id:i).temperature.curr_temp
      dew_point=Datarecord.where(update_time: latest_time,record_source:'api',record_type:'tem').find_by(location_id:i).temperature.dew_point
      sub_hash={"temp"=>temp, "dew_point"=>dew_point}
      api_hash.store("#{Location.get_location_hash["#{i}"]["location"]}",sub_hash)
    end
    return api_hash
  end

  def self.get_bom_hash
    latest_time=Datarecord.last.update_time
    bom_hash=Hash.new
    for i in (0..Location.get_location_quantity-1)
      temp=Datarecord.where(update_time: latest_time,record_source:'bom',record_type:'tem').find_by(location_id:i).temperature.curr_temp
      dew_point=Datarecord.where(update_time: latest_time,record_source:'bom',record_type:'tem').find_by(location_id:i).temperature.dew_point
      sub_hash={"temp"=>temp, "dew_point"=>dew_point}
      bom_hash.store("#{Location.get_location_hash["#{i}"]["location"]}",sub_hash)
    end
    return bom_hash
  end

  def self.get_full_hash
    full_hash={"bom"=>self.get_bom_hash,"api"=>self.get_api_hash}
    return full_hash
  end

end
