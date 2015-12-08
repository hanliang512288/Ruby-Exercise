class AddLocationToDatarecord < ActiveRecord::Migration
  def change
    add_reference :datarecords, :location, index: true
    add_foreign_key :datarecords, :locations
  end
end
