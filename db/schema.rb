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

ActiveRecord::Schema[8.0].define(version: 2025_06_18_191528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.datetime "deleted_at"
    t.integer "like_count", default: 0, null: false
    t.integer "reply_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "location"
    t.string "link"
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_events_on_team_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "likeable_type", null: false
    t.bigint "likeable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.integer "parent_id"
    t.boolean "pinned", default: false, null: false
    t.datetime "deleted_at"
    t.integer "like_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_count", default: 0, null: false
    t.bigint "topic_id"
    t.index ["topic_id"], name: "index_messages_on_topic_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "pinned_pages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "page_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["user_id"], name: "index_pinned_pages_on_user_id"
  end

  create_table "runs", force: :cascade do |t|
    t.decimal "distance", precision: 6, scale: 3, null: false
    t.date "date"
    t.text "notes"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.interval "duration"
    t.string "strava_id"
    t.string "strava_url"
    t.integer "like_count", default: 0, null: false
    t.integer "reply_count", default: 0, null: false
    t.boolean "allow_comments", default: true, null: false
    t.index ["strava_id"], name: "index_runs_on_strava_id", unique: true
    t.index ["user_id"], name: "index_runs_on_user_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.string "target_type", null: false
    t.integer "target_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true
    t.index ["target_type", "target_id"], name: "index_settings_on_target_type_and_target_id"
  end

  create_table "strava_webhook_subscriptions", force: :cascade do |t|
    t.integer "subscription_id"
    t.string "callback_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_audits", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.string "attribute_name"
    t.text "old_value"
    t.text "new_value"
    t.datetime "changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_audits_on_team_id"
  end

  create_table "team_join_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "request_number", default: 1
    t.index ["team_id"], name: "index_team_join_requests_on_team_id"
    t.index ["user_id"], name: "index_team_join_requests_on_user_id"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mileage_goal"
    t.integer "long_run_goal"
    t.boolean "included_in_stats", default: true, null: false
    t.boolean "allowed_to_edit_goals", default: true, null: false
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
    t.index ["user_id"], name: "index_team_memberships_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "season_start_date"
    t.date "season_end_date"
    t.integer "mileage_goal"
    t.integer "long_run_goal"
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["owner_id"], name: "index_teams_on_owner_id"
  end

  create_table "topics", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.string "title", null: false
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "main", default: false, null: false
    t.index ["team_id", "main"], name: "index_topics_on_team_id_and_main", unique: true, where: "main"
    t.index ["team_id", "title"], name: "index_topics_on_team_id_and_title", unique: true
    t.index ["team_id"], name: "index_topics_on_team_id"
  end

  create_table "user_topics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "topic_id", null: false
    t.boolean "favorited", default: false, null: false
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_user_topics_on_topic_id"
    t.index ["user_id", "topic_id"], name: "index_user_topics_on_user_id_and_topic_id", unique: true
    t.index ["user_id"], name: "index_user_topics_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "display_name"
    t.string "phone_number"
    t.string "gender"
    t.string "uid"
    t.string "avatar_url"
    t.string "provider"
    t.datetime "password_changed_at"
    t.string "phone_country_code"
    t.string "strava_uid"
    t.string "strava_access_token"
    t.string "strava_refresh_token"
    t.datetime "strava_token_expires_at"
    t.string "strava_accepted_scope"
    t.index ["display_name"], name: "index_users_on_display_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true, where: "(phone_number IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "users"
  add_foreign_key "events", "teams"
  add_foreign_key "likes", "users"
  add_foreign_key "messages", "topics"
  add_foreign_key "messages", "users"
  add_foreign_key "pinned_pages", "users"
  add_foreign_key "runs", "users"
  add_foreign_key "team_audits", "teams"
  add_foreign_key "team_join_requests", "teams"
  add_foreign_key "team_join_requests", "users"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "teams", "users", column: "owner_id"
  add_foreign_key "topics", "teams"
  add_foreign_key "user_topics", "topics"
  add_foreign_key "user_topics", "users"
end
