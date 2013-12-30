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

ActiveRecord::Schema.define(version: 20131230070643) do

  create_table "details", force: true do |t|
    t.integer  "user_id"
    t.integer  "amount"
    t.text     "desc"
    t.integer  "type_id"
    t.integer  "meta_id"
    t.boolean  "deleted"
    t.string   "timestamps"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "details", ["meta_id"], name: "index_details_on_meta_id"
  add_index "details", ["type_id"], name: "index_details_on_type_id"
  add_index "details", ["user_id"], name: "index_details_on_user_id"

end
