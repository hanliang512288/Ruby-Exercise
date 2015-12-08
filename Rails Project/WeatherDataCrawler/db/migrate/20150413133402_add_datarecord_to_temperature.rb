class AddDatarecordToTemperature < ActiveRecord::Migration
  def change
    add_reference :temperatures, :datarecord, index: true
    add_foreign_key :temperatures, :datarecords
  end
end
