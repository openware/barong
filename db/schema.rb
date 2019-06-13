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

ActiveRecord::Schema.define(version: 2019_05_29_114214) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "target_uid"
    t.string "category"
    t.string "user_ip", null: false
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
    t.bigint "user_id", null: false, unsigned: true
    t.string "kid", null: false
    t.string "algorithm", null: false
    t.string "scope"
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_apikeys_on_user_id"
  end

  create_table "documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "upload"
    t.string "doc_type"
    t.string "doc_number"
    t.date "doc_expire"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "labels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "key", null: false
    t.string "value", null: false
    t.string "scope", default: "public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "key", "scope"], name: "index_labels_on_user_id_and_key_and_scope"
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
    t.string "number", null: false
    t.string "code", limit: 5
    t.datetime "validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_phones_on_number"
    t.index ["user_id"], name: "index_phones_on_user_id"
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "address"
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.integer "level", default: 0, null: false
    t.boolean "otp", default: false
    t.string "state", default: "pending", null: false
    t.bigint "referral_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
