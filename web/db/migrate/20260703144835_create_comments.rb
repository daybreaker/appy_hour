class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.integer :status
      t.references :commentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
