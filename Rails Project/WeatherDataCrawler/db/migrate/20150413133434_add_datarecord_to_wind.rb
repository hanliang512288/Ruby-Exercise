class AddDatarecordToWind < ActiveRecord::Migration
  def change
    add_reference :winds, :datarecord, index: true
    add_foreign_key :winds, :datarecords
  end
end
