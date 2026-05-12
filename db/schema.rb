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

ActiveRecord::Schema[8.1].define(version: 2026_05_12_105811) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    # SQLite 호환을 위해 jsonb_path_ops/gin 인덱스 제거 (PostgreSQL 전용)
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.bigint "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.boolean "by_admin", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "demo_request_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["demo_request_id"], name: "index_comments_on_demo_request_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contact_inquiries", force: :cascade do |t|
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "handled", default: false, null: false
    t.integer "industry", default: 0, null: false
    t.string "locale", default: "ko", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_contact_inquiries_on_created_at"
    t.index ["email"], name: "index_contact_inquiries_on_email"
    t.index ["handled"], name: "index_contact_inquiries_on_handled"
  end

  create_table "demo_requests", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.text "data_description"
    t.string "locale", default: "ko", null: false
    t.string "meeting_url"
    t.datetime "preferred_at"
    t.datetime "scheduled_at"
    t.string "source"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_demo_requests_on_created_at"
    t.index ["status"], name: "index_demo_requests_on_status"
    t.index ["user_id"], name: "index_demo_requests_on_user_id"
  end

  create_table "downloads", force: :cascade do |t|
    t.integer "asset", default: 0, null: false
    t.string "company"
    t.datetime "created_at", null: false
    t.string "download_token", null: false
    t.integer "downloaded_count", default: 0, null: false
    t.string "email", null: false
    t.string "locale", default: "ko", null: false
    t.string "name"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_downloads_on_created_at"
    t.index ["download_token"], name: "index_downloads_on_download_token", unique: true
    t.index ["email"], name: "index_downloads_on_email"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "industry", default: 0, null: false
    t.string "locale", default: "ko", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["industry"], name: "index_users_on_industry"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "demo_requests"
  add_foreign_key "comments", "users"
  add_foreign_key "demo_requests", "users"
end
