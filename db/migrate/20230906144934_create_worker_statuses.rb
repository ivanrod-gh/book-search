class CreateWorkerStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :worker_statuses do |t|
      t.integer :pid
      t.datetime :started_at
      t.datetime :cooldown_until
      t.string :cooldown_reason
      t.integer :try, default: 0, null: false

      t.timestamps
    end
  end
end
