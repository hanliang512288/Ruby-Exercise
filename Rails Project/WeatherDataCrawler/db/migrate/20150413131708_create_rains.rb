class CreateRains < ActiveRecord::Migration
  def change
    create_table :rains do |t|
      t.float :rain_fall

      t.timestamps null: false
    end
  end
end
