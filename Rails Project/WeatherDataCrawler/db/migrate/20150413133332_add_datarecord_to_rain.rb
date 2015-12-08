class AddDatarecordToRain < ActiveRecord::Migration
  def change
    add_reference :rains, :datarecord, index: true
    add_foreign_key :rains, :datarecords
  end
end
