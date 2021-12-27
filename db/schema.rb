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

ActiveRecord::Schema.define(version: 2021_12_27_130101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_ip", null: false
    t.string "user_agent", null: false
    t.string "topic", null: false
    t.string "action", null: false
    t.string "result", null: false
    t.text "data"
    t.datetime "created_at"
    t.string "target_uid"
    t.string "category"
    t.string "user_ip_country"
    t.index ["target_uid"], name: "index_activities_on_target_uid"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "apikeys", force: :cascade do |t|
    t.string "kid", null: false
    t.string "algorithm", null: false
    t.string "scope"
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "secret_encrypted", limit: 1024
    t.bigint "key_holder_account_id", null: false
    t.string "key_holder_account_type", default: "User", null: false
    t.index ["key_holder_account_type", "key_holder_account_id"], name: "idx_apikey_on_account"
    t.index ["kid"], name: "index_apikeys_on_kid", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "author_uid", limit: 16, null: false
    t.string "title", limit: 64, null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "data_storages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", limit: 64, null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "title"], name: "index_data_storages_on_user_id_and_title", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "upload"
    t.string "doc_type"
    t.date "doc_expire"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identificator"
    t.date "doc_issue"
    t.string "doc_category"
    t.string "doc_number_encrypted"
    t.bigint "doc_number_index"
    t.index ["doc_number_index"], name: "index_documents_on_doc_number_index"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "domain_hosts", force: :cascade do |t|
    t.string "domain", null: false
    t.string "host", null: false
    t.index ["host"], name: "index_domain_hosts_on_host", unique: true
  end

  create_table "labels", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.string "scope", default: "public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.index ["user_id", "key", "scope"], name: "index_labels_on_user_id_and_key_and_scope", unique: true
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "levels", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action", null: false
    t.string "role", null: false
    t.string "verb", null: false
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "topic"
    t.string "domain", default: "default", null: false
    t.index ["role", "action", "verb", "path"], name: "permission_uniqueness", unique: true
    t.index ["topic"], name: "index_permissions_on_topic"
  end

  create_table "phones", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "country", null: false
    t.string "code", limit: 5
    t.datetime "validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number_encrypted", null: false
    t.bigint "number_index", null: false
    t.index ["number_index"], name: "index_phones_on_number_index"
    t.index ["user_id"], name: "index_phones_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", limit: 2, default: 0
    t.string "applicant_id"
    t.string "author"
    t.string "first_name_encrypted", limit: 1024
    t.string "last_name_encrypted", limit: 1024
    t.string "dob_encrypted"
    t.string "address_encrypted", limit: 1024
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "restrictions", force: :cascade do |t|
    t.string "scope", limit: 64, null: false
    t.string "value", limit: 64, null: false
    t.string "state", limit: 16, default: "enabled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "code"
    t.string "category", null: false
  end

  create_table "service_accounts", force: :cascade do |t|
    t.string "uid", null: false
    t.bigint "owner_id"
    t.string "email", null: false
    t.string "role", default: "service_account", null: false
    t.integer "level", default: 0, null: false
    t.string "state", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.integer "level", default: 0, null: false
    t.boolean "otp", default: false
    t.string "state", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "referral_id"
    t.text "data"
    t.string "username"
    t.integer "api_keys_limit", default: 1, null: false
    t.integer "rate_limit_level", default: 1, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true, where: "(username IS NOT NULL)"
  end

end
