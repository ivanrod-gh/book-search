class CreateRemoteParseGoals < ActiveRecord::Migration[6.1]
  def change
    create_table :remote_parse_goals do |t|
      t.belongs_to :genre, foreign_key: true
      t.string :order, null: false, default: 'desc'
      t.integer :limit, null: false, default: 1000
      t.datetime :date, null: false
      t.integer :wday, null: false, default: 1
      t.integer :hour, null: false, default: 2
      t.integer :min, null: false, default: 0
      t.integer :weeks_delay, null: false, default: 0

      t.timestamps
    end
  end
end
