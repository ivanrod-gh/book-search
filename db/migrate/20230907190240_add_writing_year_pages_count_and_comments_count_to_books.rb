class AddWritingYearPagesCountAndCommentsCountToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :writing_year, :integer
    add_index :books, :writing_year
    add_column :books, :pages_count, :integer
    add_index :books, :pages_count
    add_column :books, :comments_count, :integer
    add_index :books, :comments_count
  end
end
