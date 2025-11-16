class CreateMenuItemDeals < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_deals do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.string  :name, null: false
      t.integer :deal_type, null: false, default: 2 # set_price as common
      t.integer :price_cents
      t.integer :amount_off_cents
      t.integer :percent_off
      t.integer :bogo_buy_qty
      t.integer :bogo_get_qty
      t.integer :min_qty
      t.integer :base_price_cents
      t.integer :effective_price_cents
      t.string  :currency, null: false, default: 'USD'
      t.jsonb   :tags, default: {}
      t.boolean :active, default: true, null: false
      t.integer :priority, default: 0, null: false

      t.timestamps
    end

    add_index :menu_item_deals, [:menu_id, :deal_type, :active, :priority], name: 'idx_deals_menu_type_active_prio'
    add_index :menu_item_deals, :effective_price_cents
    add_index :menu_item_deals, :tags, using: :gin
  end
end
