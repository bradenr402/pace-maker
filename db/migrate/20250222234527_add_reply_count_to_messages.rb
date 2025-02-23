class AddReplyCountToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :reply_count, :integer, null: false, default: 0
  end
end
