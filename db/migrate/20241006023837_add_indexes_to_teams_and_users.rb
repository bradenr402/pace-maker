class AddIndexesToTeamsAndUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :teams, :name, unique: true unless index_exists?(:teams, :name)

    add_index :users, :display_name unless index_exists?(:users, :display_name)
  end
end
