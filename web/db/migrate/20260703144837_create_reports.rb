class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :reason
      t.text :notes
      t.datetime :resolved_at
      t.references :reportable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
