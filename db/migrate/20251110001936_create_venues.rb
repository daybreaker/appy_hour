class CreateVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues do |t|
      t.string :name
      t.text :description
      t.string :website_url
      t.jsonb :social_handles
      t.string :tz_name
      t.string :address
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip_code

      t.st_point :location, geographic: true, srid: 4326, null: true

      t.timestamps
    end

    add_index :venues, :location, using: :gist
    add_index :venues, :tz_name
  end
end
