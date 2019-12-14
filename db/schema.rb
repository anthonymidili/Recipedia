# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_14_023357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.citext "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "categorizations", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["recipe_id"], name: "index_categorizations_on_recipe_id"
  end

  create_table "favoritisms", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_favoritisms_on_recipe_id"
    t.index ["user_id"], name: "index_favoritisms_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.citext "item"
    t.string "quantity"
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "part_id", null: false
    t.index ["part_id"], name: "index_ingredients_on_part_id"
    t.index ["recipe_id"], name: "index_ingredients_on_recipe_id"
  end

  create_table "parts", force: :cascade do |t|
    t.string "name"
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_parts_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.citext "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "source"
    t.boolean "published", default: false
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "steps", force: :cascade do |t|
    t.text "description"
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "part_id", null: false
    t.integer "step_order", null: false
    t.index ["part_id"], name: "index_steps_on_part_id"
    t.index ["recipe_id"], name: "index_steps_on_recipe_id"
  end

  create_table "users", force: :cascade do |t|
    t.citext "username", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "slug", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "recipes"
  add_foreign_key "favoritisms", "recipes"
  add_foreign_key "favoritisms", "users"
  add_foreign_key "ingredients", "recipes"
  add_foreign_key "parts", "recipes"
  add_foreign_key "steps", "recipes"
end
