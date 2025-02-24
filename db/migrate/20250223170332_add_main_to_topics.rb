class AddMainToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :main, :boolean, default: false, null: false

    add_index :topics, [:team_id, :main], unique: true, where: 'main'
  end
end
