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

ActiveRecord::Schema[8.1].define(version: 2025_11_10_002139) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "postgis"

  create_table "hours", force: :cascade do |t|
    t.time "closes_at", null: false
    t.datetime "created_at", null: false
    t.integer "days_of_week", default: [], null: false, array: true
    t.date "effective_from"
    t.date "effective_to"
    t.integer "kind", default: 0, null: false
    t.string "note"
    t.time "opens_at", null: false
    t.boolean "overnight", default: false, null: false
    t.bigint "schedulable_id", null: false
    t.string "schedulable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["closes_at"], name: "index_hours_on_closes_at"
    t.index ["days_of_week"], name: "index_hours_on_days_of_week", using: :gin
    t.index ["opens_at"], name: "index_hours_on_opens_at"
    t.index ["schedulable_type", "schedulable_id", "kind"], name: "idx_hours_sched_kind"
    t.index ["schedulable_type", "schedulable_id"], name: "index_hours_on_schedulable"
  end

  create_table "menu_item_deals", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "amount_off_cents"
    t.integer "base_price_cents"
    t.integer "bogo_buy_qty"
    t.integer "bogo_get_qty"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.integer "deal_type", default: 2, null: false
    t.integer "effective_price_cents"
    t.bigint "menu_id", null: false
    t.bigint "menu_item_id", null: false
    t.integer "min_qty"
    t.string "name", null: false
    t.integer "percent_off"
    t.integer "price_cents"
    t.integer "priority", default: 0, null: false
    t.jsonb "tags", default: {}
    t.datetime "updated_at", null: false
    t.index ["effective_price_cents"], name: "index_menu_item_deals_on_effective_price_cents"
    t.index ["menu_id", "deal_type", "active", "priority"], name: "idx_deals_menu_type_active_prio"
    t.index ["menu_id"], name: "index_menu_item_deals_on_menu_id"
    t.index ["menu_item_id"], name: "index_menu_item_deals_on_menu_item_id"
    t.index ["tags"], name: "index_menu_item_deals_on_tags", using: :gin
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer "base_price_cents"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.text "description"
    t.integer "item_type", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id", null: false
    t.index ["venue_id", "item_type"], name: "index_menu_items_on_venue_id_and_item_type"
    t.index ["venue_id", "name"], name: "index_menu_items_on_venue_id_and_name", unique: true
    t.index ["venue_id"], name: "index_menu_items_on_venue_id"
  end

  create_table "menus", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "effective_from"
    t.date "effective_to"
    t.string "name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id", null: false
    t.index ["effective_from", "effective_to"], name: "index_menus_on_effective_from_and_effective_to"
    t.index ["venue_id", "active", "priority"], name: "index_menus_on_venue_id_and_active_and_priority"
    t.index ["venue_id"], name: "index_menus_on_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "address"
    t.string "address_2"
    t.string "city"
    t.datetime "created_at", null: false
    t.text "description"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "name"
    t.jsonb "social_handles"
    t.string "state"
    t.string "tz_name"
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.string "zip_code"
    t.index ["location"], name: "index_venues_on_location", using: :gist
    t.index ["tz_name"], name: "index_venues_on_tz_name"
  end

  add_foreign_key "menu_item_deals", "menu_items"
  add_foreign_key "menu_item_deals", "menus"
  add_foreign_key "menu_items", "venues"
  add_foreign_key "menus", "venues"
end
