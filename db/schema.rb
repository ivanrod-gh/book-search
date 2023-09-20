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

ActiveRecord::Schema.define(version: 2023_09_08_184802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_genres", "books"
  add_foreign_key "book_genres", "genres"
  add_foreign_key "book_ratings", "books"
  add_foreign_key "book_ratings", "ratings"
  add_foreign_key "remote_parse_goals", "genres"
end
