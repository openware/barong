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

ActiveRecord::Schema.define(version: 2021_04_07_094208) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "target_uid"
    t.string "category"
    t.string "user_ip", null: false
    t.string "user_ip_country"
    t.string "user_agent", null: false
    t.string "topic", null: false
    t.string "action", null: false
    t.string "result", null: false
    t.text "data"
    t.timestamp "created_at"
    t.index ["target_uid"], name: "index_activities_on_target_uid"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "apikeys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "key_holder_account_id", null: false, unsigned: true
    t.string "key_holder_account_type", default: "User", null: false
    t.string "kid", null: false
    t.string "algorithm", null: false
    t.string "scope"
    t.string "secret_encrypted", limit: 1024
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_holder_account_type", "key_holder_account_id"], name: "idx_apikey_on_account"
    t.index ["kid"], name: "index_apikeys_on_kid", unique: true
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "author_uid", limit: 16, null: false
    t.string "title", limit: 64, null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "data_storages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "title", limit: 64, null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "title"], name: "index_data_storages_on_user_id_and_title", unique: true
  end

  create_table "documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "upload"
    t.string "doc_type"
    t.date "doc_expire"
    t.string "doc_number_encrypted"
    t.bigint "doc_number_index"
    t.date "doc_issue"
    t.string "doc_category"
    t.string "identificator"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doc_number_index"], name: "index_documents_on_doc_number_index"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "labels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "key", null: false
    t.string "value", null: false
    t.string "scope", default: "public", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "key", "scope"], name: "index_labels_on_user_id_and_key_and_scope", unique: true
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "action", null: false
    t.string "role", null: false
    t.string "verb", null: false
    t.string "path", null: false
    t.string "topic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic"], name: "index_permissions_on_topic"
  end

  create_table "phones", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false, unsigned: true
    t.string "country", null: false
    t.string "code", limit: 5
    t.string "number_encrypted", null: false
    t.bigint "number_index", null: false
    t.datetime "validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number_index"], name: "index_phones_on_number_index"
    t.index ["user_id"], name: "index_phones_on_user_id"
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.string "author"
    t.string "applicant_id"
    t.string "first_name_encrypted", limit: 1024
    t.string "last_name_encrypted", limit: 1024
    t.string "dob_encrypted"
    t.string "address_encrypted", limit: 1024
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.integer "state", limit: 1, default: 0, unsigned: true
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "restrictions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "category", null: false
    t.string "scope", limit: 64, null: false
    t.string "value", limit: 64, null: false
    t.integer "code"
    t.string "state", limit: 16, default: "enabled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uid", null: false
    t.bigint "owner_id", unsigned: true
    t.string "email", null: false
    t.string "role", default: "service_account", null: false
    t.integer "level", default: 0, null: false
    t.string "state", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uid", null: false
    t.string "username"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.text "data"
    t.integer "level", default: 0, null: false
    t.boolean "otp", default: false
    t.string "state", default: "pending", null: false
    t.bigint "referral_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
