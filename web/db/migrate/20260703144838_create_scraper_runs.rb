class CreateScraperRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :scraper_runs do |t|
      t.references :venue, null: false, foreign_key: true
      t.datetime :run_at, null: false
      t.integer :result, null: false, default: 0
      t.text :notes
      t.jsonb :raw_data

      t.timestamps
    end

    add_index :scraper_runs, :result
    add_index :scraper_runs, :run_at
  end
end
