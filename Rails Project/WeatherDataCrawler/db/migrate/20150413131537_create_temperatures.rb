class CreateTemperatures < ActiveRecord::Migration
  def change
    create_table :temperatures do |t|
      t.float :curr_temp
      t.float :dew_point

      t.timestamps null: false
    end
  end
end
