# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140423005817) do

  create_table "assignment_submissions", :force => true do |t|
    t.integer  "user_id",                          :null => false
    t.integer  "assignment_id",                    :null => false
    t.string   "body"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.binary   "zip_file"
    t.boolean  "is_finalized",  :default => false
    t.integer  "specs_passing"
  end

  add_index "assignment_submissions", ["assignment_id"], :name => "index_assignment_submissions_on_assignment_id"
  add_index "assignment_submissions", ["user_id"], :name => "index_assignment_submissions_on_user_id"

  create_table "assignments", :force => true do |t|
    t.string   "name",                                             :null => false
    t.text     "info",                                             :null => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "group_type_id",                                    :null => false
    t.string   "submission_policy"
    t.datetime "due_date"
    t.string   "submission_format",       :default => "plaintext", :null => false
    t.boolean  "is_due_date_compulsary",  :default => false
    t.string   "slug"
    t.string   "filepath_regex"
    t.boolean  "is_visible",              :default => true
    t.string   "submission_instructions"
    t.boolean  "visible_comments",        :default => true
  end

  add_index "assignments", ["group_type_id"], :name => "index_assignments_on_group_type_id"
  add_index "assignments", ["slug"], :name => "index_assignments_on_slug", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "assignment_submission_id",                    :null => false
    t.integer  "user_id"
    t.integer  "mark"
    t.string   "body"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "peer_review_cycle_id"
    t.boolean  "has_file",                 :default => false
    t.integer  "parent_id"
    t.string   "file_name"
    t.string   "explicit_filepath"
    t.integer  "custom_behavior_id"
  end

  add_index "comments", ["assignment_submission_id"], :name => "index_comments_on_assignment_submission_id"
  add_index "comments", ["parent_id"], :name => "index_comments_on_parent_id"
  add_index "comments", ["peer_review_cycle_id"], :name => "index_comments_on_peer_review_cycle_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "courses", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "convener_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "slug"
  end

  add_index "courses", ["slug"], :name => "index_courses_on_slug", :unique => true

  create_table "custom_behaviors", :force => true do |t|
    t.integer  "assignment_id", :null => false
    t.string   "name",          :null => false
    t.string   "details"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "extensions", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "assignment_id", :null => false
    t.datetime "due_date",      :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "group_course_memberships", :force => true do |t|
    t.integer  "course_id",     :null => false
    t.integer  "group_type_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "group_course_memberships", ["course_id"], :name => "index_group_course_memberships_on_course_id"
  add_index "group_course_memberships", ["group_type_id"], :name => "index_group_course_memberships_on_group_type_id"

  create_table "group_staff_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "group_staff_memberships", ["group_id"], :name => "index_group_staff_memberships_on_group_id"
  add_index "group_staff_memberships", ["user_id"], :name => "index_group_staff_memberships_on_user_id"

  create_table "group_student_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "group_student_memberships", ["group_id"], :name => "index_group_student_memberships_on_group_id"
  add_index "group_student_memberships", ["user_id"], :name => "index_group_student_memberships_on_user_id"

  create_table "group_types", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "group_types", ["name"], :name => "index_group_types_on_name", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name",          :null => false
    t.integer  "group_type_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "groups", ["group_type_id"], :name => "index_groups_on_group_type_id"

  create_table "marking_categories", :force => true do |t|
    t.integer  "assignment_id", :null => false
    t.string   "name",          :null => false
    t.string   "description",   :null => false
    t.integer  "maximum_mark",  :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "marking_categories", ["assignment_id"], :name => "index_marking_categories_on_assignment_id"

  create_table "marks", :force => true do |t|
    t.integer  "value",               :null => false
    t.integer  "comment_id",          :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "marking_category_id"
  end

  add_index "marks", ["comment_id"], :name => "index_marks_on_comment_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "notable_type"
    t.integer  "notable_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "message"
  end

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "peer_marks", :force => true do |t|
    t.integer  "comment_id", :null => false
    t.integer  "value",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "peer_marks", ["comment_id"], :name => "index_peer_marks_on_comment_id"

  create_table "peer_review_cycles", :force => true do |t|
    t.integer  "assignment_id",                          :null => false
    t.string   "distribution_scheme",                    :null => false
    t.boolean  "shut_off_submission", :default => false, :null => false
    t.boolean  "anonymise",           :default => false, :null => false
    t.datetime "activation_time"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "activated",           :default => false
    t.integer  "maximum_mark"
    t.integer  "number_of_swaps"
  end

  add_index "peer_review_cycles", ["assignment_id"], :name => "index_peer_review_cycles_on_assignment_id"

  create_table "staff_enrollments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "course_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "staff_enrollments", ["course_id"], :name => "index_staff_enrollments_on_course_id"
  add_index "staff_enrollments", ["user_id"], :name => "index_staff_enrollments_on_user_id"

  create_table "student_enrollments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "course_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "student_enrollments", ["course_id"], :name => "index_student_enrollments_on_course_id"
  add_index "student_enrollments", ["user_id"], :name => "index_student_enrollments_on_user_id"

  create_table "submission_files", :force => true do |t|
    t.integer  "assignment_submission_id"
    t.string   "name"
    t.string   "body"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.binary   "file_blob"
  end

  create_table "submission_permissions", :force => true do |t|
    t.integer  "assignment_submission_id", :null => false
    t.integer  "user_id",                  :null => false
    t.integer  "peer_review_cycle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submission_permissions", ["assignment_submission_id"], :name => "index_submission_permissions_on_assignment_submission_id"
  add_index "submission_permissions", ["peer_review_cycle_id"], :name => "index_submission_permissions_on_peer_review_cycle_id"
  add_index "submission_permissions", ["user_id"], :name => "index_submission_permissions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name",                             :null => false
    t.integer  "uni_id",                           :null => false
    t.string   "session_token",                    :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_admin",      :default => false, :null => false
    t.boolean  "is_fake",       :default => false
  end

  add_index "users", ["uni_id"], :name => "index_users_on_uni_id"

end
