class CreateHappyHourDays < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_hour_days do |t|
      t.references :happy_hour, null: false, foreign_key: true
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time
      t.date :specific_date

      t.timestamps
    end
  end
end
