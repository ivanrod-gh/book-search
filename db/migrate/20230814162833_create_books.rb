class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :int_id, null: false, index: {unique: true}
      t.string :name
      t.datetime :date, index: true

      t.timestamps
    end
  end
end
