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

ActiveRecord::Schema[8.0].define(version: 2025_07_23_221657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
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
    t.string "company_name"
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

  create_table "equipment", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.date "purchase_date"
    t.decimal "acquisition_price"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.string "location"
    t.date "acquisition_date"
    t.text "observations"
    t.string "category"
    t.string "subcategory"
    t.bigint "power_option_id"
    t.string "power"
    t.string "voltage"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_equipment_on_category_id"
    t.index ["power_option_id"], name: "index_equipment_on_power_option_id"
  end

  create_table "equipment_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "equipments", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "serial_number"
    t.string "model"
    t.string "brand"
    t.string "status"
    t.bigint "equipment_category_id", null: false
    t.date "purchase_date"
    t.decimal "purchase_value"
    t.date "maintenance_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_category_id"], name: "index_equipments_on_equipment_category_id"
  end

  create_table "financial_transactions", force: :cascade do |t|
    t.bigint "rental_id", null: false
    t.string "transaction_type"
    t.decimal "amount"
    t.text "description"
    t.date "transaction_date"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rental_id"], name: "index_financial_transactions_on_rental_id"
  end

  create_table "power_options", force: :cascade do |t|
    t.integer "value"
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rentals", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "equipment_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.decimal "daily_rate"
    t.decimal "total_value"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_rentals_on_client_id"
    t.index ["equipment_id"], name: "index_rentals_on_equipment_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "status"
    t.string "priority"
    t.bigint "assigned_to_id", null: false
    t.bigint "created_by_id", null: false
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_tasks_on_assigned_to_id"
    t.index ["created_by_id"], name: "index_tasks_on_created_by_id"
  end

  create_table "transformer_mts", force: :cascade do |t|
    t.bigint "equipment_id", null: false
    t.string "voltage_level"
    t.string "capacity"
    t.string "manufacturer"
    t.string "model"
    t.date "installation_date"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id"], name: "index_transformer_mts_on_equipment_id"
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
  add_foreign_key "equipment", "categories"
  add_foreign_key "equipment", "power_options"
  add_foreign_key "equipments", "equipment_categories"
  add_foreign_key "financial_transactions", "rentals"
  add_foreign_key "rentals", "clients"
  add_foreign_key "rentals", "equipments"
  add_foreign_key "tasks", "users", column: "assigned_to_id"
  add_foreign_key "tasks", "users", column: "created_by_id"
  add_foreign_key "transformer_mts", "equipment"
end
