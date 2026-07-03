class CreateHappyHourItems < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_hour_items do |t|
      t.references :happy_hour_day, null: false, foreign_key: true
      t.string :name
      t.string :category
      t.decimal :original_price
      t.decimal :happy_hour_price
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
