class CreateSearches < ActiveRecord::Migration[6.1]
  def change
    create_table :searches do |t|
      t.belongs_to :user, foreign_key: true
      # t.text :query
      t.integer :genre_filter
      t.integer :start_date_filter
      t.integer :end_date_filter
      t.integer :rating_litres_average_filter
      t.integer :rating_litres_votes_count_filter
      t.integer :rating_livelib_average_filter
      t.integer :rating_livelib_votes_count_filter
      t.integer :writing_year_filter
      t.integer :pages_count_filter
      t.integer :comments_count_filter
      t.integer :genre_int_id
      t.integer :start_date_added_3i
      t.integer :start_date_added_2i
      t.integer :start_date_added_1i
      t.integer :end_date_added_3i
      t.integer :end_date_added_2i
      t.integer :end_date_added_1i
      t.integer :rating_litres_average
      t.integer :rating_litres_votes_count
      t.integer :rating_livelib_average
      t.integer :rating_livelib_votes_count
      t.integer :writing_year
      t.integer :pages_count
      t.integer :comments_count

      t.timestamps
    end
  end
end
