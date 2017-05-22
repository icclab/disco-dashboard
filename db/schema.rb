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

ActiveRecord::Schema.define(version: 20161212102621) do

  create_table "assignments", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_assignments_on_group_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

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
    t.string   "state",                           default: "DEPLOYING"
    t.string   "name"
    t.integer  "master_image_id"
    t.integer  "slave_image_id"
    t.integer  "master_flavor_id"
    t.integer  "slave_flavor_id"
    t.integer  "slave_num"
    t.integer  "external_ip",           limit: 8, default: 0
    t.string   "ssh_private_key"
    t.boolean  "slave_on_master"
    t.integer  "infrastructure_id"
    t.string   "slave_flavor_memory"
    t.string   "slave_flavor_disk"
    t.string   "slave_flavor_vcpu"
    t.string   "master_flavor_memory"
    t.string   "master_flavor_disk"
    t.string   "master_flavor_vcpu"
    t.string   "master_image_name"
    t.string   "slave_image_name"
    t.string   "openstack_clustername"
    t.boolean  "is_suspended",                    default: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "group_id"
    t.index ["group_id"], name: "index_clusters_on_group_id"
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

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string   "region"
    t.string   "provider"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_infrastructures_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name"
    t.string   "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "group_id"
    t.index ["group_id"], name: "index_tasks_on_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "role"
    t.boolean  "admin",           default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
