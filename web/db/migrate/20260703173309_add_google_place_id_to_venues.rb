class AddGooglePlaceIdToVenues < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :google_place_id, :string
    add_index :venues, :google_place_id, unique: true
  end
end
