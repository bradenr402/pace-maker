class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: false, index: true
      t.datetime :deleted_at
      t.integer :like_count, default: 0, null: false
      t.integer :reply_count, default: 0, null: false

      t.timestamps
    end
  end
end
