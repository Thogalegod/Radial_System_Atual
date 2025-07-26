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

ActiveRecord::Schema[8.0].define(version: 2025_07_26_001746) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bt_options", force: :cascade do |t|
    t.integer "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "cpf_cnpj"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_type"
    t.string "document_number"
    t.string "zip_code"
    t.string "state_registration"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "position"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_primary", default: false
    t.index ["client_id"], name: "index_contacts_on_client_id"
  end

  create_table "cooling_options", force: :cascade do |t|
    t.string "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flag_options", force: :cascade do |t|
    t.string "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "installation_options", force: :cascade do |t|
    t.string "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medium_voltage_transformers", force: :cascade do |t|
    t.string "serial_number"
    t.string "location"
    t.text "notes"
    t.bigint "bt_option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id"
    t.bigint "status_id"
    t.bigint "power_option_id"
    t.bigint "cooling_option_id"
    t.bigint "flag_option_id"
    t.bigint "installation_option_id"
    t.index ["bt_option_id"], name: "index_medium_voltage_transformers_on_bt_option_id"
    t.index ["cooling_option_id"], name: "index_medium_voltage_transformers_on_cooling_option_id"
    t.index ["flag_option_id"], name: "index_medium_voltage_transformers_on_flag_option_id"
    t.index ["installation_option_id"], name: "index_medium_voltage_transformers_on_installation_option_id"
    t.index ["location_id"], name: "index_medium_voltage_transformers_on_location_id"
    t.index ["power_option_id"], name: "index_medium_voltage_transformers_on_power_option_id"
    t.index ["status_id"], name: "index_medium_voltage_transformers_on_status_id"
  end

  create_table "power_options", force: :cascade do |t|
    t.integer "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "value"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
  end

  add_foreign_key "contacts", "clients"
  add_foreign_key "medium_voltage_transformers", "bt_options"
  add_foreign_key "medium_voltage_transformers", "cooling_options"
  add_foreign_key "medium_voltage_transformers", "flag_options"
  add_foreign_key "medium_voltage_transformers", "installation_options"
  add_foreign_key "medium_voltage_transformers", "locations"
  add_foreign_key "medium_voltage_transformers", "power_options"
  add_foreign_key "medium_voltage_transformers", "statuses"
end
