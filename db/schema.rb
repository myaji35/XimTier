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

ActiveRecord::Schema[8.1].define(version: 2026_09_01_000000) do
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

  create_table "case_comments", force: :cascade do |t|
    t.string "author_name", null: false
    t.text "body", null: false
    t.integer "case_study_id", null: false
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["case_study_id", "status"], name: "index_case_comments_on_case_study_id_and_status"
    t.index ["case_study_id"], name: "index_case_comments_on_case_study_id"
  end

  create_table "case_likes", force: :cascade do |t|
    t.integer "case_study_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visitor_token", null: false
    t.index ["case_study_id", "visitor_token"], name: "index_case_likes_on_case_study_id_and_visitor_token", unique: true
    t.index ["case_study_id"], name: "index_case_likes_on_case_study_id"
  end

  create_table "case_media", force: :cascade do |t|
    t.text "caption"
    t.integer "case_study_id", null: false
    t.datetime "created_at", null: false
    t.text "embed_html"
    t.integer "kind", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "youtube_url"
    t.index ["case_study_id", "position"], name: "index_case_media_on_case_study_id_and_position"
    t.index ["case_study_id"], name: "index_case_media_on_case_study_id"
  end

  create_table "case_studies", force: :cascade do |t|
    t.text "body_html_en"
    t.text "body_html_ko"
    t.datetime "created_at", null: false
    t.string "industry"
    t.integer "likes_count", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.text "summary_en"
    t.text "summary_ko"
    t.string "title_en"
    t.string "title_ko", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_case_studies_on_position"
    t.index ["published", "published_at"], name: "index_case_studies_on_published_and_published_at"
    t.index ["slug"], name: "index_case_studies_on_slug", unique: true
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
    t.text "admin_notes"
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "handled", default: false, null: false
    t.integer "industry", default: 0, null: false
    t.string "locale", default: "ko", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.datetime "privacy_agreed_at"
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
    t.text "admin_notes"
    t.integer "asset", default: 0, null: false
    t.string "company"
    t.datetime "contacted_at"
    t.datetime "created_at", null: false
    t.string "download_token", null: false
    t.integer "downloaded_count", default: 0, null: false
    t.string "email", null: false
    t.boolean "handled", default: false, null: false
    t.string "investor_kind"
    t.string "locale", default: "ko", null: false
    t.string "name"
    t.datetime "privacy_agreed_at"
    t.string "role"
    t.datetime "token_issued_at"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_downloads_on_created_at"
    t.index ["download_token"], name: "index_downloads_on_download_token", unique: true
    t.index ["email"], name: "index_downloads_on_email"
    t.index ["handled"], name: "index_downloads_on_handled"
    t.index ["investor_kind"], name: "index_downloads_on_investor_kind"
  end

  create_table "email_opt_outs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "reason"
    t.string "source", null: false
    t.index ["email"], name: "index_email_opt_outs_on_email", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "KRW", null: false
    t.datetime "failed_at"
    t.text "failure_reason"
    t.datetime "paid_at"
    t.string "payment_id", null: false
    t.string "payment_method"
    t.string "plan_code", null: false
    t.string "portone_tx_id"
    t.json "raw_response", default: {}
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["payment_id"], name: "index_payments_on_payment_id", unique: true
    t.index ["portone_tx_id"], name: "index_payments_on_portone_tx_id", unique: true
    t.index ["status"], name: "index_payments_on_status"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "company"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "industry", default: 0, null: false
    t.string "locale", default: "ko", null: false
    t.string "name"
    t.datetime "privacy_agreed_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "suspended_at"
    t.string "suspension_reason"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["industry"], name: "index_users_on_industry"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["suspended_at"], name: "index_users_on_suspended_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "case_comments", "case_studies"
  add_foreign_key "case_likes", "case_studies"
  add_foreign_key "case_media", "case_studies"
  add_foreign_key "comments", "demo_requests"
  add_foreign_key "comments", "users"
  add_foreign_key "demo_requests", "users"
  add_foreign_key "payments", "users"
end
