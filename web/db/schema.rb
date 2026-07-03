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

ActiveRecord::Schema[8.1].define(version: 2026_07_03_171302) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "commentable_id", null: false
    t.string "commentable_type", null: false
    t.datetime "created_at", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "favorite_venues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "venue_id", null: false
    t.index ["user_id"], name: "index_favorite_venues_on_user_id"
    t.index ["venue_id"], name: "index_favorite_venues_on_venue_id"
  end

  create_table "happy_hour_bogos", force: :cascade do |t|
    t.string "applies_to"
    t.integer "buy_quantity"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "get_discount_type"
    t.decimal "get_discount_value"
    t.integer "get_quantity"
    t.bigint "happy_hour_day_id", null: false
    t.string "item_name"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["happy_hour_day_id"], name: "index_happy_hour_bogos_on_happy_hour_day_id"
  end

  create_table "happy_hour_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.time "end_time"
    t.bigint "happy_hour_id", null: false
    t.date "specific_date"
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["happy_hour_id"], name: "index_happy_hour_days_on_happy_hour_id"
  end

  create_table "happy_hour_generics", force: :cascade do |t|
    t.string "applies_to"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount_type"
    t.decimal "discount_value"
    t.bigint "happy_hour_day_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["happy_hour_day_id"], name: "index_happy_hour_generics_on_happy_hour_day_id"
  end

  create_table "happy_hour_items", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "happy_hour_day_id", null: false
    t.decimal "happy_hour_price"
    t.string "name"
    t.decimal "original_price"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["happy_hour_day_id"], name: "index_happy_hour_items_on_happy_hour_day_id"
  end

  create_table "happy_hours", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "source_url"
    t.integer "status", default: 0, null: false
    t.bigint "submitted_by_id"
    t.datetime "updated_at", null: false
    t.bigint "venue_id", null: false
    t.index ["approved_by_id"], name: "index_happy_hours_on_approved_by_id"
    t.index ["status"], name: "index_happy_hours_on_status"
    t.index ["submitted_by_id"], name: "index_happy_hours_on_submitted_by_id"
    t.index ["venue_id"], name: "index_happy_hours_on_venue_id"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "name"], name: "index_neighborhoods_on_city_and_name", unique: true
    t.index ["slug"], name: "index_neighborhoods_on_slug", unique: true
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "rateable_id", null: false
    t.string "rateable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "value"
    t.index ["rateable_type", "rateable_id"], name: "index_ratings_on_rateable"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "reason"
    t.bigint "reportable_id", null: false
    t.string "reportable_type", null: false
    t.datetime "resolved_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "scraper_runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.jsonb "raw_data"
    t.integer "result", default: 0, null: false
    t.datetime "run_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id", null: false
    t.index ["result"], name: "index_scraper_runs_on_result"
    t.index ["run_at"], name: "index_scraper_runs_on_run_at"
    t.index ["venue_id"], name: "index_scraper_runs_on_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "name", null: false
    t.boolean "needs_investigation", default: false, null: false
    t.bigint "neighborhood_id"
    t.string "phone"
    t.integer "scraper_status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.string "zip_code"
    t.index ["city"], name: "index_venues_on_city"
    t.index ["discarded_at"], name: "index_venues_on_discarded_at"
    t.index ["lonlat"], name: "index_venues_on_lonlat", using: :gist
    t.index ["needs_investigation"], name: "index_venues_on_needs_investigation"
    t.index ["neighborhood_id"], name: "index_venues_on_neighborhood_id"
    t.index ["zip_code"], name: "index_venues_on_zip_code"
  end

  add_foreign_key "comments", "users"
  add_foreign_key "favorite_venues", "users"
  add_foreign_key "favorite_venues", "venues"
  add_foreign_key "happy_hour_bogos", "happy_hour_days"
  add_foreign_key "happy_hour_days", "happy_hours"
  add_foreign_key "happy_hour_generics", "happy_hour_days"
  add_foreign_key "happy_hour_items", "happy_hour_days"
  add_foreign_key "happy_hours", "users", column: "approved_by_id"
  add_foreign_key "happy_hours", "users", column: "submitted_by_id"
  add_foreign_key "happy_hours", "venues"
  add_foreign_key "ratings", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "scraper_runs", "venues"
  add_foreign_key "venues", "neighborhoods"
end
