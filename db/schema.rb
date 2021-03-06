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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150423164717) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buyer_groups", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters", force: true do |t|
    t.string "filter_name"
    t.text   "filter_elements"
    t.string "page"
  end

  create_table "inventory_projections", force: true do |t|
    t.integer  "location_id"
    t.integer  "product_id"
    t.date     "projected_for"
    t.decimal  "available_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  create_table "location_groups", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "address"
    t.string   "city"
    t.string   "state_providence"
    t.string   "country"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.integer  "organization_id"
    t.integer  "location_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestones", force: true do |t|
    t.string   "associated_object_type"
    t.integer  "associated_object_id"
    t.string   "milestone_type"
    t.string   "reason_code"
    t.string   "city"
    t.string   "country"
    t.decimal  "quantity"
    t.integer  "customer_organization_id"
    t.integer  "create_organization_id"
    t.integer  "create_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reference_number"
  end

  create_table "order_itineraries", force: true do |t|
    t.integer  "order_line_id"
    t.integer  "shipment_line_id"
    t.integer  "leg_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "next_order_itinerary_id"
  end

  create_table "order_lines", force: true do |t|
    t.string   "order_line_number"
    t.decimal  "quantity"
    t.date     "eta"
    t.date     "etd"
    t.integer  "origin_location_id"
    t.integer  "destination_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_organization_id"
    t.integer  "customer_organization_id"
    t.integer  "product_id"
    t.boolean  "is_active"
    t.string   "order_type"
    t.integer  "status",                   default: 0
    t.integer  "buyer_group_id"
    t.decimal  "total_cost"
  end

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_categories", force: true do |t|
    t.string   "description"
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_category_id"
    t.decimal  "unit_cost"
    t.decimal  "unit_weight"
    t.decimal  "unit_volume"
  end

  create_table "saved_search_criteria", force: true do |t|
    t.string   "name"
    t.string   "page"
    t.text     "search_parameters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  create_table "scv_exceptions", force: true do |t|
    t.string   "exception_type"
    t.integer  "priority"
    t.integer  "status"
    t.integer  "affected_object_id"
    t.string   "affected_object_type"
    t.string   "affected_object_quantity_type"
    t.decimal  "affected_object_quantity"
    t.string   "affected_object_date_type"
    t.date     "affected_object_date"
    t.integer  "cause_object_id"
    t.string   "cause_object_type"
    t.string   "cause_object_quantity_type"
    t.decimal  "cause_object_quantity"
    t.string   "cause_object_date_type"
    t.date     "cause_object_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipment_lines", force: true do |t|
    t.string   "shipment_line_number"
    t.decimal  "quantity"
    t.date     "eta"
    t.date     "etd"
    t.integer  "origin_location_id"
    t.integer  "destination_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mode"
    t.integer  "carrier_organization_id"
    t.integer  "forwarder_organization_id"
    t.integer  "customer_organization_id"
    t.integer  "product_id"
    t.boolean  "is_active"
    t.string   "shipment_type"
    t.integer  "status",                    default: 0
    t.decimal  "total_cost"
    t.decimal  "total_weight"
    t.decimal  "total_volume"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "saved_search_criterium_id"
  end

  create_table "work_orders", force: true do |t|
    t.string   "work_order_number"
    t.integer  "product_id"
    t.integer  "location_id"
    t.date     "production_begin_date"
    t.integer  "quantity"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active"
    t.date     "production_end_date"
  end

end
