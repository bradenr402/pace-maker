class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.references :team, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :closed_at

      t.timestamps
    end

    add_index :topics, [:team_id, :title], unique: true
  end
end
