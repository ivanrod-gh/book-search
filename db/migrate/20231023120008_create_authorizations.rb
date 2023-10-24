class CreateAuthorizations < ActiveRecord::Migration[6.1]
  def change
    create_table :authorizations do |t|
      t.belongs_to :user, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.index %i[provider uid], unique: true

      t.timestamps
    end
  end
end
