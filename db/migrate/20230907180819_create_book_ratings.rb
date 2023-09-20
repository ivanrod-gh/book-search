class CreateBookRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :book_ratings do |t|
      t.belongs_to :book, foreign_key: true
      t.belongs_to :rating, foreign_key: true
      t.float :average, null: false, index: true
      t.integer :votes_count, null: false, index: true

      t.timestamps
    end
  end
end
