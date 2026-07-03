class CreateFavoriteVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :favorite_venues do |t|
      t.references :user, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true

      t.timestamps
    end
  end
end
