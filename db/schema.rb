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

ActiveRecord::Schema.define(version: 20131121211917) do

  create_table "admins", force: true do |t|
    t.integer  "user_id"
    t.string   "flags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "admins", ["user_id"], name: "index_admins_on_user_id", using: :btree

  create_table "api_keys", force: true do |t|
    t.string   "name"
    t.string   "access_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "map_comments", force: true do |t|
    t.integer  "map_id"
    t.integer  "user_id"
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "map_comments", ["map_id"], name: "index_map_comments_on_map_id", using: :btree
  add_index "map_comments", ["user_id"], name: "index_map_comments_on_user_id", using: :btree

  create_table "map_favorites", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "map_id"
  end

  add_index "map_favorites", ["map_id"], name: "index_map_favorites_on_map_id", using: :btree
  add_index "map_favorites", ["user_id"], name: "index_map_favorites_on_user_id", using: :btree

  create_table "map_types", force: true do |t|
    t.string   "name"
    t.string   "prefix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "maps", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "map_type_id"
    t.text     "description",        default: ""
    t.string   "origin",             default: ""
    t.integer  "likes_count",        default: 0
    t.integer  "hates_count",        default: 0
    t.integer  "map_comments_count", default: 0
    t.datetime "last_played_at"
    t.integer  "total_time_played",  default: 0
  end

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.string   "avatar_url"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "admin",           default: false, null: false
    t.datetime "banned_at"
    t.boolean  "moderator",       default: false, null: false
    t.string   "avatar_icon_url"
  end

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "map_id"
    t.integer  "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "votes", ["map_id"], name: "index_votes_on_map_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
