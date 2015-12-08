# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150423094544) do

  create_table "datarecords", force: :cascade do |t|
    t.datetime "update_time"
    t.string   "record_source"
    t.string   "record_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "location_id"
  end

  add_index "datarecords", ["location_id"], name: "index_datarecords_on_location_id"

  create_table "locations", force: :cascade do |t|
    t.string   "location_name"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "rains", force: :cascade do |t|
    t.float    "rain_fall"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "datarecord_id"
  end

  add_index "rains", ["datarecord_id"], name: "index_rains_on_datarecord_id"

  create_table "temperatures", force: :cascade do |t|
    t.float    "curr_temp"
    t.float    "dew_point"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "datarecord_id"
  end

  add_index "temperatures", ["datarecord_id"], name: "index_temperatures_on_datarecord_id"

  create_table "winds", force: :cascade do |t|
    t.float    "wind_speed"
    t.float    "wind_direction"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "datarecord_id"
  end

  add_index "winds", ["datarecord_id"], name: "index_winds_on_datarecord_id"

end
