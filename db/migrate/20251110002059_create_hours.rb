class CreateHours < ActiveRecord::Migration[8.1]
  def change
    create_table :hours do |t|
      t.references :schedulable, polymorphic: true, null: false
      t.integer :kind, null: false, default: 0  # 0:operating, 1:menu
      t.integer :days_of_week, array: true, default: [], null: false
      t.time    :opens_at,  null: false
      t.time    :closes_at, null: false
      t.boolean :overnight, default: false, null: false
      t.date :effective_from
      t.date :effective_to
      t.string :note

      t.timestamps
    end

    add_index :hours, [:schedulable_type, :schedulable_id, :kind], name: 'idx_hours_sched_kind'
    add_index :hours, :days_of_week, using: :gin
    add_index :hours, :opens_at
    add_index :hours, :closes_at
  end
end
