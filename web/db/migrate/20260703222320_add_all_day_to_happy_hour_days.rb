class AddAllDayToHappyHourDays < ActiveRecord::Migration[8.1]
  def change
    add_column :happy_hour_days, :all_day, :boolean, null: false, default: false
  end
end
