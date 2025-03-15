class AddLikeCountAndReplyCountToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :like_count, :integer, default: 0, null: false
    add_column :runs, :reply_count, :integer, default: 0, null: false
  end
end
