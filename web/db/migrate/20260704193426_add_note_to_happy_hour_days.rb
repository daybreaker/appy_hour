class AddNoteToHappyHourDays < ActiveRecord::Migration[8.1]
  def change
    add_column :happy_hour_days, :note, :string
  end
end
