class CreateGenres < ActiveRecord::Migration[6.1]
  def change
    create_table :genres do |t|
      t.string :int_id, null: false, index: {unique: true}
      t.string :name, null: false

      t.timestamps
    end
  end
end
