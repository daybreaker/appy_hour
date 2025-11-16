class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.integer :priority, default: 0, null: false
      t.date :effective_from
      t.date :effective_to

      t.timestamps
    end

    add_index :menus, [:venue_id, :active, :priority]
    add_index :menus, [:effective_from, :effective_to]
  end
end
