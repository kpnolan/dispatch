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

ActiveRecord::Schema.define(version: 20130709140336) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agencies", force: true do |t|
    t.string   "code",       limit: 2
    t.string   "name",       limit: 63
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "abbrev",     limit: 3
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "distpatches", force: true do |t|
    t.integer  "category_id"
    t.datetime "published"
    t.float    "point_lat"
    t.float    "point_long"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "updated"
    t.string   "address"
    t.integer  "agency_id"
    t.string   "responder_id", limit: 14, null: false
    t.datetime "last_updated",            null: false
  end

  add_index "distpatches", ["agency_id"], name: "index_distpatches_on_agency_id", using: :btree
  add_index "distpatches", ["category_id"], name: "index_distpatches_on_category_id", using: :btree
  add_index "distpatches", ["responder_id"], name: "index_distpatches_on_responder_id", unique: true, using: :btree

end
