class CreateNeighborhoods < ActiveRecord::Migration[8.1]
  def change
    create_table :neighborhoods do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :neighborhoods, :slug, unique: true
    add_index :neighborhoods, [ :city, :name ], unique: true
  end
end
