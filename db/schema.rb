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

ActiveRecord::Schema.define(version: 20161011150141) do

  create_table "clusters", force: :cascade do |t|
    t.string   "uuid"
    t.string   "state"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "name"
    t.string   "master_name"
    t.string   "slave_name"
    t.string   "master_image"
    t.string   "slave_image"
    t.string   "master_flavor"
    t.string   "slave_flavor"
    t.integer  "master_num"
    t.integer  "slave_num"
    t.boolean  "master_slave"
    t.integer  "external_ip",   limit: 8
    t.index ["user_id", "uuid"], name: "index_clusters_on_user_id_and_uuid"
    t.index ["user_id"], name: "index_clusters_on_user_id"
    t.index ["uuid"], name: "index_clusters_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.string   "auth_url"
    t.string   "tenant"
    t.string   "disco_ip"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
