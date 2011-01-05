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

ActiveRecord::Schema.define(:version => 20110104222352) do

  create_table "conflicts", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "member_id"
    t.integer  "motion_id"
    t.string   "event_type"
    t.boolean  "value",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["member_id", "event_type"], :name => "member_events_by_event_type"
  add_index "events", ["member_id", "motion_id", "event_type"], :name => "event_validation_of_member_event_type", :unique => true
  add_index "events", ["motion_id", "event_type"], :name => "motion_events_by_event_type"
  add_index "events", ["motion_id", "value"], :name => "motion_events_by_value"

  create_table "member_conflicts", :force => true do |t|
    t.integer  "member_id"
    t.integer  "conflict_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
  end

  add_index "members", ["email"], :name => "index_members_on_email", :unique => true
  add_index "members", ["reset_password_token"], :name => "index_members_on_reset_password_token", :unique => true

  create_table "memberships", :force => true do |t|
    t.integer  "member_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "qualifying_motion_id"
    t.integer  "disqualifying_motion_id"
    t.boolean  "is_admin"
  end

  add_index "memberships", ["ended_at"], :name => "index_memberships_on_ended_at"
  add_index "memberships", ["member_id"], :name => "index_memberships_on_member_id"
  add_index "memberships", ["started_at"], :name => "index_memberships_on_started_at"

  create_table "motion_conflicts", :force => true do |t|
    t.integer  "motion_id"
    t.integer  "conflict_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motions", :force => true do |t|
    t.integer  "member_id"
    t.string   "title"
    t.string   "state_name",  :default => "waitingsecond"
    t.text     "description"
    t.text     "rationale"
    t.integer  "abstains"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "expedited",   :default => false
    t.datetime "closed_at"
  end

  add_index "motions", ["member_id"], :name => "index_motions_on_member_id"

  create_table "taggings", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "motion_id"
  end

  add_index "taggings", ["tag_id", "motion_id"], :name => "index_taggings_on_tag_id_and_motion_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
