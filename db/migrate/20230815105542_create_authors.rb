class CreateAuthors < ActiveRecord::Migration[6.1]
  def change
    create_table :authors do |t|
      t.string :int_id, null: false, index: {unique: true}
      t.string :name, null: false
      t.string :url

      t.timestamps
    end
  end
end
