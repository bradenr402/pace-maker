class AddAllowCommentsToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :allow_comments, :boolean, default: true, null: false
  end
end
