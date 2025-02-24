class AddTopicToMessages < ActiveRecord::Migration[8.0]
  def change
    add_reference :messages, :topic, foreign_key: true
  end
end
