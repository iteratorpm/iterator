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

ActiveRecord::Schema[8.0].define(version: 2025_04_22_103251) do
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

  create_table "attachments", force: :cascade do |t|
    t.string "filename", null: false
    t.string "content_type"
    t.integer "file_size"
    t.string "file_path", null: false
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.integer "uploader_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id"
    t.index ["uploader_id"], name: "index_attachments_on_uploader_id"
  end

  create_table "blockers", force: :cascade do |t|
    t.text "description", null: false
    t.boolean "resolved", default: false
    t.integer "story_id", null: false
    t.integer "blocker_story_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocker_story_id"], name: "index_blockers_on_blocker_story_id"
    t.index ["resolved"], name: "index_blockers_on_resolved"
    t.index ["story_id"], name: "index_blockers_on_story_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "csv_exports", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "filename"
    t.integer "filesize"
    t.integer "state", default: 0, null: false
    t.text "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_csv_exports_on_project_id"
  end

  create_table "description_templates", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_description_templates_on_project_id"
  end

  create_table "epics", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "project_id", null: false
    t.integer "label_id", null: false
    t.string "external_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_epics_on_label_id"
    t.index ["project_id"], name: "index_epics_on_project_id"
  end

  create_table "github_integrations", force: :cascade do |t|
    t.string "api_url"
    t.string "webhook_secret"
    t.string "oauth_token"
    t.string "oauth_refresh_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "github_repositories", force: :cascade do |t|
    t.integer "github_integration_id", null: false
    t.string "name", null: false
    t.string "external_id", null: false
    t.bigint "webhook_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_integration_id", "external_id"], name: "idx_on_github_integration_id_external_id_d697261199", unique: true
    t.index ["github_integration_id"], name: "index_github_repositories_on_github_integration_id"
  end

  create_table "integrations", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "creator_id", null: false
    t.string "name", null: false
    t.string "integration_type", null: false
    t.string "provider_type"
    t.bigint "provider_id"
    t.json "config"
    t.json "scopes", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_integrations_on_creator_id"
    t.index ["project_id"], name: "index_integrations_on_project_id"
    t.index ["provider_type", "provider_id"], name: "index_integrations_on_provider_type_and_provider_id"
  end

  create_table "iterations", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "length_weeks"
    t.integer "number", default: 0, null: false
    t.integer "velocity"
    t.boolean "current", default: false, null: false
    t.index ["project_id"], name: "index_iterations_on_project_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "name"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.index ["project_id", "name"], name: "index_labels_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_labels_on_project_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.integer "role", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "project_creator", default: false
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "muted_projects", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.integer "mute_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_muted_projects_on_project_id"
    t.index ["user_id", "project_id"], name: "index_muted_projects_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_muted_projects_on_user_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id"
    t.integer "story_creation", default: 0
    t.integer "comments", default: 1
    t.integer "comment_source", default: 0
    t.integer "story_state_changes", default: 1
    t.integer "blockers", default: 1
    t.integer "comment_reactions", default: 1
    t.integer "reviews", default: 1
    t.integer "in_app_state", default: 1
    t.integer "email_state", default: 1
    t.integer "mute_state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_notification_settings_on_project_id"
    t.index ["user_id", "project_id"], name: "index_notification_settings_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.integer "notification_type", null: false
    t.integer "delivery_method", default: 0, null: false
    t.datetime "read_at", precision: nil
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["project_id"], name: "index_notifications_on_project_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.integer "collaborator_limit"
    t.integer "project_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "plan_type", default: 0, null: false
    t.integer "projects_count", default: 0
    t.integer "admins_count", default: 0
    t.integer "collaborators_count", default: 0
    t.integer "active_projects_count", default: 0
  end

  create_table "project_memberships", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.integer "role", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_project_memberships_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "description"
    t.integer "organization_id"
    t.boolean "enable_tasks", default: true
    t.boolean "public", default: false
    t.integer "iteration_start_day", default: 0
    t.date "start_date"
    t.string "time_zone"
    t.integer "iteration_length", default: 1
    t.integer "point_scale", default: 0
    t.string "point_scale_custom", default: ""
    t.integer "initial_velocity", default: 10
    t.integer "velocity_scheme", default: 0
    t.integer "done_iterations_to_show", default: 4
    t.boolean "auto_iteration_planning", default: true
    t.boolean "allow_api_access", default: true
    t.boolean "enable_incoming_emails", default: true
    t.boolean "hide_email_addresses", default: false
    t.boolean "priority_field_enabled", default: false
    t.integer "priority_display_scope", default: 0
    t.boolean "point_bugs_and_chores", default: false
    t.integer "project_memberships_count", default: 0
    t.integer "stories_count", default: 0
    t.boolean "archived", default: false
    t.text "profile_content"
    t.integer "velocity"
    t.boolean "automatic_planning", default: true
    t.index ["organization_id"], name: "index_projects_on_organization_id"
  end

  create_table "review_types", force: :cascade do |t|
    t.string "name"
    t.boolean "hidden", default: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_review_types_on_project_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "state", default: 0
    t.text "comment"
    t.integer "story_id", null: false
    t.integer "reviewer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["story_id"], name: "index_reviews_on_story_id"
  end

  create_table "stories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "story_type", default: 0
    t.integer "state", default: 0
    t.integer "priority", default: 2
    t.integer "estimate"
    t.integer "project_id", null: false
    t.integer "requester_id"
    t.integer "epic_id"
    t.integer "iteration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.datetime "rejected_at"
    t.datetime "accepted_at"
    t.datetime "started_at"
    t.date "deadline"
    t.date "completion_date"
    t.index ["discarded_at"], name: "index_stories_on_discarded_at"
    t.index ["epic_id"], name: "index_stories_on_epic_id"
    t.index ["iteration_id"], name: "index_stories_on_iteration_id"
    t.index ["priority"], name: "index_stories_on_priority"
    t.index ["project_id"], name: "index_stories_on_project_id"
    t.index ["requester_id"], name: "index_stories_on_requester_id"
    t.index ["state"], name: "index_stories_on_state"
    t.index ["story_type"], name: "index_stories_on_story_type"
  end

  create_table "story_followers", force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "user_id"], name: "index_story_followers_on_story_id_and_user_id", unique: true
    t.index ["story_id"], name: "index_story_followers_on_story_id"
    t.index ["user_id"], name: "index_story_followers_on_user_id"
  end

  create_table "story_labels", force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "label_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_story_labels_on_label_id"
    t.index ["story_id", "label_id"], name: "index_story_labels_on_story_id_and_label_id", unique: true
    t.index ["story_id"], name: "index_story_labels_on_story_id"
  end

  create_table "story_owners", force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "user_id"], name: "index_story_owners_on_story_id_and_user_id", unique: true
    t.index ["story_id"], name: "index_story_owners_on_story_id"
    t.index ["user_id"], name: "index_story_owners_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.text "description", null: false
    t.boolean "completed", default: false
    t.integer "story_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_tasks_on_completed"
    t.index ["story_id"], name: "index_tasks_on_story_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "name", default: "", null: false
    t.string "initials", default: "", null: false
    t.boolean "admin", default: false
    t.integer "current_organization_id"
    t.string "time_zone"
    t.string "api_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["current_organization_id"], name: "index_users_on_current_organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object", limit: 1073741823
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.integer "integration_id", null: false
    t.integer "state", default: 0
    t.integer "event_type", default: 0
    t.json "payload"
    t.integer "attempts", default: 0
    t.datetime "last_attempt_at"
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_webhook_events_on_integration_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.string "webhook_url"
    t.boolean "enabled", default: false
    t.integer "failure_count", default: 0
    t.text "last_response_body"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_webhooks_on_project_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "users", column: "uploader_id"
  add_foreign_key "blockers", "stories"
  add_foreign_key "blockers", "stories", column: "blocker_story_id"
  add_foreign_key "comments", "users", column: "author_id"
  add_foreign_key "csv_exports", "projects"
  add_foreign_key "description_templates", "projects"
  add_foreign_key "epics", "labels"
  add_foreign_key "epics", "projects"
  add_foreign_key "github_repositories", "github_integrations"
  add_foreign_key "integrations", "users", column: "creator_id"
  add_foreign_key "iterations", "projects"
  add_foreign_key "labels", "projects"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "muted_projects", "projects"
  add_foreign_key "muted_projects", "users"
  add_foreign_key "notification_settings", "projects"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "notifications", "projects"
  add_foreign_key "notifications", "users"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "users"
  add_foreign_key "projects", "organizations"
  add_foreign_key "review_types", "projects"
  add_foreign_key "reviews", "stories"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "stories", "epics"
  add_foreign_key "stories", "iterations"
  add_foreign_key "stories", "projects"
  add_foreign_key "stories", "users", column: "requester_id"
  add_foreign_key "story_followers", "stories"
  add_foreign_key "story_followers", "users"
  add_foreign_key "story_labels", "labels"
  add_foreign_key "story_labels", "stories"
  add_foreign_key "story_owners", "stories"
  add_foreign_key "story_owners", "users"
  add_foreign_key "tasks", "stories"
  add_foreign_key "users", "organizations", column: "current_organization_id"
  add_foreign_key "webhook_events", "integrations"
  add_foreign_key "webhooks", "projects"
end
