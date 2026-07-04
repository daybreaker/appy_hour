class MoveDealsToHappyHour < ActiveRecord::Migration[8.1]
  def change
    # Deals now belong to the happy hour (the menu) rather than an individual
    # day, so one menu's deals are entered once and apply across all its days.
    %i[happy_hour_generics happy_hour_items happy_hour_bogos].each do |table|
      remove_reference table, :happy_hour_day, foreign_key: true, index: true
      add_reference table, :happy_hour, null: false, foreign_key: true
    end
  end
end
