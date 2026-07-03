class CreateSocialLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :social_links do |t|
      t.references :venue, null: false, foreign_key: true
      t.integer :platform, null: false, default: 7
      t.string :url, null: false

      t.timestamps
    end

    add_index :social_links, [ :venue_id, :url ], unique: true
  end
end
