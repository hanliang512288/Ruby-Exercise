class CreateDatarecords < ActiveRecord::Migration
  def change
    create_table :datarecords do |t|
      t.integer :update_time
      t.string :record_source
      t.string :record_type

      t.timestamps null: false
    end
  end
end
