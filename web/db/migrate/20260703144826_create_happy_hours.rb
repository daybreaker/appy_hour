class CreateHappyHours < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_hours do |t|
      t.references :venue, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.text :notes
      t.datetime :approved_at
      t.bigint :submitted_by_id
      t.bigint :approved_by_id

      t.timestamps
    end

    add_index :happy_hours, :status
    add_index :happy_hours, :submitted_by_id
    add_index :happy_hours, :approved_by_id
    add_foreign_key :happy_hours, :users, column: :submitted_by_id
    add_foreign_key :happy_hours, :users, column: :approved_by_id
  end
end
