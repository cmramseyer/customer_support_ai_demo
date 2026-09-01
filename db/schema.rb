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

ActiveRecord::Schema[8.1].define(version: 2026_09_01_213000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id", "created_at"], name: "index_comments_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_comments_on_product_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "knowledge_base_chunks", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.vector "embedding", limit: 1536
    t.bigint "knowledge_base_document_id", null: false
    t.integer "position", null: false
    t.integer "token_count", null: false
    t.datetime "updated_at", null: false
    t.index ["embedding"], name: "index_knowledge_base_chunks_on_embedding", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["knowledge_base_document_id", "position"], name: "idx_on_knowledge_base_document_id_position_ce82b0a0a3", unique: true
    t.index ["knowledge_base_document_id"], name: "index_knowledge_base_chunks_on_knowledge_base_document_id"
    t.check_constraint "\"position\" >= 0", name: "knowledge_base_chunks_position_nonnegative"
    t.check_constraint "token_count > 0", name: "knowledge_base_chunks_token_count_positive"
  end

  create_table "knowledge_base_documents", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "payment_method", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.integer "status", default: 0, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "payment_method::text = ANY (ARRAY['cash'::character varying, 'credit_card'::character varying, 'gift_card'::character varying]::text[])", name: "orders_payment_method_valid"
    t.check_constraint "quantity >= 1 AND quantity <= 99", name: "orders_quantity_between_1_and_99"
    t.check_constraint "status = ANY (ARRAY[0, 1])", name: "orders_status_valid"
  end

  create_table "products", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "comments", "products"
  add_foreign_key "comments", "users"
  add_foreign_key "knowledge_base_chunks", "knowledge_base_documents"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
end
