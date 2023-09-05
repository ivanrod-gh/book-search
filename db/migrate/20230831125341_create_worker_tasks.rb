class CreateWorkerTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :worker_tasks do |t|
      t.string :name, null: false
      t.text :data

      t.timestamps
    end
  end
end
