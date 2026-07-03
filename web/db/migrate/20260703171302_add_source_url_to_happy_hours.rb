class AddSourceUrlToHappyHours < ActiveRecord::Migration[8.1]
  def change
    add_column :happy_hours, :source_url, :string
  end
end
