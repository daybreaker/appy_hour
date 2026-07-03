class CreateHappyHourBogos < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_hour_bogos do |t|
      t.references :happy_hour_day, null: false, foreign_key: true
      t.integer :buy_quantity
      t.integer :get_quantity
      t.integer :get_discount_type
      t.decimal :get_discount_value
      t.string :applies_to
      t.string :item_name
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
