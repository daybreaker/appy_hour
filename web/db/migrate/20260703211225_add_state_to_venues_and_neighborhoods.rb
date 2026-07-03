class AddStateToVenuesAndNeighborhoods < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :state, :string
    add_column :neighborhoods, :state, :string

    # Same city+name can now exist in different states (e.g. Cleveland OH vs TN).
    remove_index :neighborhoods, column: [ :city, :name ], unique: true
    add_index :neighborhoods, [ :state, :city, :name ], unique: true
  end
end
