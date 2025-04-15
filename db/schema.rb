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

ActiveRecord::Schema[8.0].define(version: 2025_04_15_161403) do
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

  create_table "epics", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "project_id", null: false
    t.integer "label_id", null: false
    t.string "external_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_epics_on_label_id"
    t.index ["project_id"], name: "index_epics_on_project_id"
  end

  create_table "iterations", force: :cascade do |t|
    t.date "starts_on"
    t.date "ends_on"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.integer "owner_id", null: false
    t.integer "seats_limit"
    t.integer "projects_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "description"
    t.integer "organization_id"
    t.boolean "enable_tasks", default: true
    t.boolean "public_access", default: false
    t.integer "iteration_start_day", default: 0
    t.date "project_start_date"
    t.integer "project_time_zone", default: 0
    t.integer "iteration_length", default: 1
    t.integer "point_scale", default: 0
    t.string "point_scale_custom", default: ""
    t.integer "initial_velocity", default: 10
    t.integer "velocity_strategy", default: 0
    t.integer "done_iterations_to_show", default: 4
    t.boolean "auto_iteration_planning", default: true
    t.boolean "allow_api_access", default: true
    t.boolean "enable_incoming_emails", default: true
    t.boolean "hide_email_addresses", default: false
    t.boolean "priority_field_enabled", default: false
    t.integer "priority_display_scope", default: 0
    t.boolean "point_bugs_and_chores", default: false
    t.index ["organization_id"], name: "index_projects_on_organization_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "status", default: 0
    t.text "comment"
    t.integer "story_id", null: false
    t.integer "reviewer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["story_id"], name: "index_reviews_on_story_id"
  end

  create_table "stories", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "story_type", default: 0
    t.integer "status", default: 0
    t.integer "priority", default: 2
    t.integer "points"
    t.integer "project_id", null: false
    t.integer "requester_id"
    t.integer "epic_id"
    t.integer "iteration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epic_id"], name: "index_stories_on_epic_id"
    t.index ["iteration_id"], name: "index_stories_on_iteration_id"
    t.index ["priority"], name: "index_stories_on_priority"
    t.index ["project_id"], name: "index_stories_on_project_id"
    t.index ["requester_id"], name: "index_stories_on_requester_id"
    t.index ["status"], name: "index_stories_on_status"
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "attachments", "users", column: "uploader_id"
  add_foreign_key "blockers", "stories"
  add_foreign_key "blockers", "stories", column: "blocker_story_id"
  add_foreign_key "comments", "users", column: "author_id"
  add_foreign_key "epics", "labels"
  add_foreign_key "epics", "projects"
  add_foreign_key "iterations", "projects"
  add_foreign_key "labels", "projects"
  add_foreign_key "organizations", "owners"
  add_foreign_key "projects", "organizations"
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
end
