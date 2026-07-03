class CreateVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :phone
      t.string :website_url
      t.references :neighborhood, null: true, foreign_key: true
      t.st_point :lonlat, geographic: true
      t.boolean :needs_investigation, null: false, default: false
      t.integer :scraper_status, null: false, default: 0
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :venues, :lonlat, using: :gist
    add_index :venues, :city
    add_index :venues, :zip_code
    add_index :venues, :discarded_at
    add_index :venues, :needs_investigation
  end
end
