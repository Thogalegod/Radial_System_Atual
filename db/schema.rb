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

ActiveRecord::Schema[8.0].define(version: 2025_07_28_184134) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_active_storage_variant_records_on_blob_id", unique: true
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

  create_table "equipment_feature_options", force: :cascade do |t|
    t.bigint "equipment_feature_id", null: false
    t.string "value", null: false
    t.string "label"
    t.string "color", default: "#6B7280"
    t.string "icon_class"
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_equipment_feature_options_on_active"
    t.index ["equipment_feature_id", "value"], name: "index_feature_options_on_feature_and_value", unique: true
    t.index ["equipment_feature_id"], name: "index_equipment_feature_options_on_equipment_feature_id"
    t.index ["sort_order"], name: "index_equipment_feature_options_on_sort_order"
  end

  create_table "equipment_features", force: :cascade do |t|
    t.bigint "equipment_type_id", null: false
    t.string "name", null: false
    t.string "data_type", null: false
    t.string "unit"
    t.text "description"
    t.boolean "required", default: false
    t.boolean "searchable", default: true
    t.boolean "filterable", default: true
    t.boolean "sortable", default: true
    t.string "default_value"
    t.text "options"
    t.string "validation_rules"
    t.string "display_format"
    t.string "color", default: "#6B7280"
    t.string "icon_class"
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_type"], name: "index_equipment_features_on_data_type"
    t.index ["equipment_type_id", "name"], name: "index_equipment_features_on_equipment_type_id_and_name", unique: true
    t.index ["equipment_type_id"], name: "index_equipment_features_on_equipment_type_id"
    t.index ["filterable"], name: "index_equipment_features_on_filterable"
    t.index ["required"], name: "index_equipment_features_on_required"
    t.index ["searchable"], name: "index_equipment_features_on_searchable"
    t.index ["sort_order"], name: "index_equipment_features_on_sort_order"
    t.index ["sortable"], name: "index_equipment_features_on_sortable"
  end

  create_table "equipment_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "icon_class", default: "fas fa-cog"
    t.string "primary_color", default: "#3B82F6"
    t.string "secondary_color", default: "#1E40AF"
    t.string "accent_color", default: "#DBEAFE"
    t.boolean "active", default: true
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_equipment_types_on_active"
    t.index ["name"], name: "index_equipment_types_on_name", unique: true
    t.index ["sort_order"], name: "index_equipment_types_on_sort_order"
  end

  create_table "equipment_values", force: :cascade do |t|
    t.bigint "equipments_id", null: false
    t.bigint "equipment_feature_id", null: false
    t.string "value"
    t.string "color", default: "#6B7280"
    t.string "style_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color"], name: "index_equipment_values_on_color"
    t.index ["equipment_feature_id"], name: "index_equipment_values_on_equipment_feature_id"
    t.index ["equipments_id", "equipment_feature_id"], name: "index_equipment_values_on_equipment_and_feature", unique: true
    t.index ["equipments_id"], name: "index_equipment_values_on_equipments_id"
    t.index ["value"], name: "index_equipment_values_on_value"
  end

  create_table "equipments", force: :cascade do |t|
    t.string "serial_number", null: false
    t.bigint "equipment_type_id", null: false
    t.text "notes"
    t.string "status", default: "active"
    t.string "location"
    t.date "acquisition_date"
    t.date "last_maintenance_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "acquisition_price", precision: 10, scale: 2
    t.string "bandeira"
    t.index ["equipment_type_id"], name: "index_equipments_on_equipment_type_id"
    t.index ["location"], name: "index_equipments_on_location"
    t.index ["serial_number"], name: "index_equipments_on_serial_number", unique: true
    t.index ["status"], name: "index_equipments_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contacts", "clients"
  add_foreign_key "equipment_feature_options", "equipment_features"
  add_foreign_key "equipment_features", "equipment_types"
  add_foreign_key "equipment_values", "equipment_features"
  add_foreign_key "equipment_values", "equipments", column: "equipments_id"
  add_foreign_key "equipments", "equipment_types"
end
