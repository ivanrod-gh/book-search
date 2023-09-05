class CreateBookAuthors < ActiveRecord::Migration[6.1]
  def change
    create_table :book_authors do |t|
      t.belongs_to :book, foreign_key: true
      t.belongs_to :author, foreign_key: true

      t.timestamps
    end
  end
end
