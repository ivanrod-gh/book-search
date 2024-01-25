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

ActiveRecord::Schema.define(version: 2024_01_25_122704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "int_id", null: false
    t.string "name", null: false
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["int_id"], name: "index_authors_on_int_id", unique: true
  end

  create_table "book_authors", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["book_id"], name: "index_book_authors_on_book_id"
  end

  create_table "book_genres", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "genre_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_book_genres_on_book_id"
    t.index ["genre_id"], name: "index_book_genres_on_genre_id"
  end

  create_table "book_ratings", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "rating_id"
    t.float "average", null: false
    t.integer "votes_count", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["average"], name: "index_book_ratings_on_average"
    t.index ["book_id"], name: "index_book_ratings_on_book_id"
    t.index ["rating_id"], name: "index_book_ratings_on_rating_id"
    t.index ["votes_count"], name: "index_book_ratings_on_votes_count"
  end

  create_table "books", force: :cascade do |t|
    t.string "int_id", null: false
    t.string "name"
    t.datetime "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "writing_year"
    t.integer "pages_count"
    t.integer "comments_count"
    t.index ["comments_count"], name: "index_books_on_comments_count"
    t.index ["date"], name: "index_books_on_date"
    t.index ["int_id"], name: "index_books_on_int_id", unique: true
    t.index ["pages_count"], name: "index_books_on_pages_count"
    t.index ["writing_year"], name: "index_books_on_writing_year"
  end

  create_table "genres", force: :cascade do |t|
    t.string "int_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["int_id"], name: "index_genres_on_int_id", unique: true
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "ratings", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_ratings_on_name", unique: true
  end

  create_table "remote_parse_goals", force: :cascade do |t|
    t.bigint "genre_id"
    t.string "order", default: "desc", null: false
    t.integer "limit", default: 1000, null: false
    t.datetime "date", null: false
    t.integer "wday", default: 1, null: false
    t.integer "hour", default: 2, null: false
    t.integer "min", default: 0, null: false
    t.integer "weeks_delay", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["genre_id"], name: "index_remote_parse_goals_on_genre_id"
  end

  create_table "searches", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "genre_filter"
    t.integer "start_date_filter"
    t.integer "end_date_filter"
    t.integer "rating_litres_average_filter"
    t.integer "rating_litres_votes_count_filter"
    t.integer "rating_livelib_average_filter"
    t.integer "rating_livelib_votes_count_filter"
    t.integer "writing_year_filter"
    t.integer "pages_count_filter"
    t.integer "comments_count_filter"
    t.integer "genre_int_id"
    t.integer "start_date_added_3i"
    t.integer "start_date_added_2i"
    t.integer "start_date_added_1i"
    t.integer "end_date_added_3i"
    t.integer "end_date_added_2i"
    t.integer "end_date_added_1i"
    t.integer "rating_litres_average"
    t.integer "rating_litres_votes_count"
    t.integer "rating_livelib_average"
    t.integer "rating_livelib_votes_count"
    t.integer "writing_year"
    t.integer "pages_count"
    t.integer "comments_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "user_books", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "book_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_user_books_on_book_id"
    t.index ["user_id", "book_id"], name: "index_user_books_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_user_books_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "worker_statuses", force: :cascade do |t|
    t.integer "pid"
    t.datetime "started_at"
    t.datetime "cooldown_until"
    t.string "cooldown_reason"
    t.integer "try", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "worker_tasks", force: :cascade do |t|
    t.string "name", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "authorizations", "users"
  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_genres", "books"
  add_foreign_key "book_genres", "genres"
  add_foreign_key "book_ratings", "books"
  add_foreign_key "book_ratings", "ratings"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "remote_parse_goals", "genres"
  add_foreign_key "searches", "users"
  add_foreign_key "user_books", "books"
  add_foreign_key "user_books", "users"
end
