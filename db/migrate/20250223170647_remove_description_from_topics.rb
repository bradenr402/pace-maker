class RemoveDescriptionFromTopics < ActiveRecord::Migration[8.0]
  def change
    remove_column :topics, :description, :text
  end
end
