class CreateHappyHourGenerics < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_hour_generics do |t|
      t.references :happy_hour_day, null: false, foreign_key: true
      t.string :applies_to
      t.integer :discount_type
      t.decimal :discount_value
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
