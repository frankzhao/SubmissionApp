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

ActiveRecord::Schema.define(:version => 20140115232756) do

  create_table "assignment_submissions", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "assignment_id", :null => false
    t.string   "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.binary   "zip_file"
  end

  create_table "assignments", :force => true do |t|
    t.string   "name",                                            :null => false
    t.text     "info",                                            :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "group_type_id",                                   :null => false
    t.string   "submission_policy"
    t.datetime "due_date"
    t.string   "submission_format",      :default => "plaintext", :null => false
    t.integer  "maximum_mark",           :default => 100,         :null => false
    t.string   "behavior_on_submission", :default => ""
    t.boolean  "is_due_date_compulsary", :default => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "assignment_submission_id", :null => false
    t.integer  "user_id"
    t.integer  "mark"
    t.string   "body"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "convener_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "group_course_memberships", :force => true do |t|
    t.integer  "course_id",     :null => false
    t.integer  "group_type_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "group_staff_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "group_student_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "peer_review_cycles", :force => true do |t|
    t.integer  "assignment_id",       :null => false
    t.string   "distribution_scheme", :null => false
    t.boolean  "get_marks",           :null => false
    t.boolean  "shut_off_submission", :null => false
    t.boolean  "anonymise",           :null => false
    t.datetime "activation_time"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "staff_enrollments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "course_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "student_enrollments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "course_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "submission_permissions", :force => true do |t|
    t.integer "assignment_submission_id", :null => false
    t.integer "user_id",                  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name",                             :null => false
    t.integer  "uni_id",                           :null => false
    t.string   "session_token",                    :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_admin",      :default => false, :null => false
  end

end
