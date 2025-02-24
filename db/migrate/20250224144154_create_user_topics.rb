class CreateUserTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :user_topics do |t|
      t.references :user, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true
      t.boolean :favorited, default: false, null: false
      t.datetime :last_read_at

      t.timestamps
    end

    add_index :user_topics, [:user_id, :topic_id], unique: true
  end
end
