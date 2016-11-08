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

ActiveRecord::Schema.define(version: 20161108132854) do

  create_table "cluster_frameworks", force: :cascade do |t|
    t.integer  "cluster_id"
    t.integer  "framework_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["cluster_id"], name: "index_cluster_frameworks_on_cluster_id"
    t.index ["framework_id"], name: "index_cluster_frameworks_on_framework_id"
  end

  create_table "clusters", force: :cascade do |t|
    t.string   "uuid"
    t.string   "state"
    t.string   "name"
    t.string   "master_image"
    t.string   "slave_image"
    t.string   "master_flavor"
    t.string   "slave_flavor"
    t.integer  "master_num"
    t.integer  "slave_num"
    t.integer  "external_ip",       limit: 8
    t.boolean  "slave_on_master"
    t.integer  "infrastructure_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["infrastructure_id"], name: "index_clusters_on_infrastructure_id"
    t.index ["uuid"], name: "index_clusters_on_uuid", unique: true
  end

  create_table "flavors", force: :cascade do |t|
    t.string   "fl_id"
    t.string   "name"
    t.integer  "vcpus"
    t.integer  "disk"
    t.integer  "ram"
    t.integer  "infrastructure_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["infrastructure_id"], name: "index_flavors_on_infrastructure_id"
  end

  create_table "frameworks", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "port"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "img_id"
    t.string   "name"
    t.integer  "size"
    t.integer  "infrastructure_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["infrastructure_id"], name: "index_images_on_infrastructure_id"
  end

  create_table "infrastructures", force: :cascade do |t|
    t.string   "name"
    t.string   "username"
    t.string   "auth_url"
    t.string   "tenant"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_infrastructures_on_user_id"
  end

  create_table "keypairs", force: :cascade do |t|
    t.integer  "infrastructure_id"
    t.string   "name"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["infrastructure_id"], name: "index_keypairs_on_infrastructure_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",           default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "usertypes", force: :cascade do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
