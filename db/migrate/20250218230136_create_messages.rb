class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :parent_id
      t.boolean :pinned, null: false, default: false
      t.datetime :deleted_at
      t.integer :like_count, null: false, default: 0

      t.timestamps
    end
  end
end
