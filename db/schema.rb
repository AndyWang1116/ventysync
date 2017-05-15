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

ActiveRecord::Schema.define(version: 20170524103256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "histories", force: :cascade do |t|
    t.string   "sync_to",    null: false
    t.string   "section",    null: false
    t.string   "action",     null: false
    t.hstore   "message",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "histories", ["action"], name: "index_histories_on_action", using: :btree
  add_index "histories", ["message"], name: "index_histories_on_message", using: :gin

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain", null: false
    t.string   "shopify_token",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shops", ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree

  create_table "sync_checkers", force: :cascade do |t|
    t.datetime "last_new_product_synced"
    t.datetime "last_edited_product_synced"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
