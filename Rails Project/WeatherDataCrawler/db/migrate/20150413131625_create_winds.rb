class CreateWinds < ActiveRecord::Migration
  def change
    create_table :winds do |t|
      t.float :wind_speed
      t.string :wind_direction

      t.timestamps null: false
    end
  end
end
