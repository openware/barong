# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_16_093540) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cryptocurrency", primary_key: "code", id: { type: :string, limit: 4 }, force: :cascade do |t|
    t.string "name", limit: 256, null: false
    t.integer "scale", limit: 2, default: 8, null: false
    t.integer "weight", limit: 2, null: false
    t.index ["name"], name: "cryptocurrency_name_key", unique: true
    t.check_constraint "length((code)::text) > 0", name: "cryptocurrency_code_check"
    t.check_constraint "length((name)::text) > 0", name: "cryptocurrency_name_check"
  end

  create_table "cryptocurrency_settings", id: false, force: :cascade do |t|
    t.string "code", null: false
    t.float "ref_trader_bonus_percent", null: false
    t.float "trade_comission_percent"
    t.decimal "hot_wallet_balance"
    t.decimal "cold_wallet_audit_adjust"
    t.boolean "withdraw_enabled", default: true, null: false
    t.boolean "deposit_enabled", default: true, null: false
    t.boolean "optimal_enabled", default: true, null: false
    t.boolean "free_enabled", default: false, null: false
    t.boolean "free_trades_enabled", default: false, null: false
    t.decimal "min_withdrawal", default: "0.0", null: false
    t.boolean "is_token", default: false, null: false
    t.float "ref_ad_bonus_percent", null: false
    t.integer "pay_many_stack", default: 1, null: false
    t.decimal "minimum_ad_enabled_amount", default: "0.0", null: false
    t.decimal "real_cold_wallet_balance", default: "0.0", null: false
    t.decimal "freeze_amount", default: "1.0", null: false
    t.boolean "trades_enabled", default: true, null: false
    t.boolean "is_shitcoin", default: false, null: false
    t.boolean "is_delisted", default: false, null: false
    t.boolean "has_cold_wallet", default: false, null: false
    t.datetime "cold_wallet_balance_updated_at"
    t.string "bot_name", limit: 126
    t.string "blockchain_url", limit: 126
    t.decimal "hot_wallet_unconfirmed_balance"
    t.decimal "min_acceptable_deposit"
    t.decimal "mature_trader_min_turnover"
    t.boolean "in_rating", default: false, null: false
    t.decimal "debt", precision: 60, scale: 8, default: "0.0", null: false
    t.interval "audit_watchdog_deposit_interval"
    t.decimal "withdraw_amount_limit"
    t.jsonb "custom"
    t.check_constraint "(NOT is_delisted) OR (NOT (trades_enabled OR withdraw_enabled OR deposit_enabled))", name: "cryptocurrency_settings_check"
    t.check_constraint "(min_acceptable_deposit)::numeric > (0)::numeric", name: "cryptocurrency_settings_min_acceptable_deposit_check"
    t.check_constraint "(withdraw_amount_limit)::numeric >= (min_withdrawal)::numeric", name: "cryptocurrency_settings_withdraw_amount_limit_check"
    t.check_constraint "debt >= (0)::numeric", name: "cryptocurrency_settings_debt_check"
  end

  create_table "rate", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.decimal "value", null: false
    t.text "url", null: false
    t.text "description", null: false
    t.string "currency_symbol", limit: 5, null: false
    t.string "cc_code", null: false
    t.boolean "default_rate", default: false, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.check_constraint "value > (0)::numeric", name: "check_values"
  end

  create_table "user", id: :integer, default: nil, force: :cascade do |t|
    t.string "subject", limit: 510, null: false
    t.string "nickname", limit: 510
    t.boolean "email_verified", null: false
    t.boolean "chat_enabled", null: false
    t.boolean "email_auth_enabled", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "telegram_id", limit: 256
    t.string "auth0_id"
    t.integer "ref_parent_user_id"
    t.integer "referrer"
    t.string "country"
    t.text "real_email"
    t.boolean "2fa_enabled", default: false, null: false
    t.boolean "authority_can_make_deal", default: true, null: false
    t.boolean "authority_can_make_order", default: true, null: false
    t.boolean "authority_can_make_voucher", default: true, null: false
    t.boolean "authority_can_make_withdrawal", default: true, null: false
    t.boolean "authority_is_admin", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "password_reset_at"
    t.string "sys_code", limit: 63
  end

  create_table "user_cryptocurrency_settings", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "cc_code", null: false
    t.boolean "trading_enabled", default: true, null: false
    t.index ["user_id", "cc_code"], name: "user_cryptocurrency_settings_user_id_cryptocurrency_code_idx", unique: true, where: "trading_enabled"
  end

  create_table "wallet", id: :integer, default: nil, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "address", limit: 800
    t.decimal "balance", default: "0.0", null: false
    t.decimal "hold_balance", default: "0.0", null: false
    t.datetime "created_at", precision: 0, default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.decimal "debt", default: "0.0", null: false
    t.string "cc_code", null: false
    t.index ["cc_code", "address"], name: "wallets_address_key", unique: true
    t.index ["user_id"], name: "wallet_user_id"
    t.check_constraint "(balance)::numeric >= (0)::numeric", name: "balance_check"
    t.check_constraint "(debt)::numeric >= (0)::numeric", name: "debt_check"
    t.check_constraint "(hold_balance)::numeric >= (0)::numeric", name: "hold_check"
  end

  add_foreign_key "cryptocurrency_settings", "cryptocurrency", column: "code", primary_key: "code", name: "cryptocurrency_settings_code_fkey"
  add_foreign_key "user_cryptocurrency_settings", "\"user\"", column: "user_id", name: "user_cryptocurrency_settings_user_id_fkey"
end
