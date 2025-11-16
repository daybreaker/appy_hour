class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :item_type, null: false, default: 0
      t.integer :base_price_cents
      t.string :currency, null: false, default: 'USD'

      t.timestamps
    end

    add_index :menu_items, [:venue_id, :item_type]
    add_index :menu_items, [:venue_id, :name], unique: true
  end
end
