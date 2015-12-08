class ChangeDataTypeForFieldname < ActiveRecord::Migration
  def change
    change_column :winds, :wind_direction, :float
  end
end
