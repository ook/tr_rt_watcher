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

ActiveRecord::Schema.define(version: 20150916065519) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "travels", force: :cascade do |t|
    t.datetime "theorically_enter_at"
    t.text     "times",                default: [],              array: true
    t.string   "num",                               null: false
    t.string   "term"
    t.string   "mission",                           null: false
    t.string   "stop_id",                           null: false
    t.string   "status"
    t.string   "ligne"
    t.string   "route"
    t.string   "date_str",                          null: false
    t.integer  "stop_sequence",                     null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "direction"
  end

  add_index "travels", ["date_str"], name: "index_travels_on_date_str", using: :btree

end
