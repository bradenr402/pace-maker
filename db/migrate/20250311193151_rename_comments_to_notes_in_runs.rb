class RenameCommentsToNotesInRuns < ActiveRecord::Migration[8.0]
  def change
    rename_column :runs, :comments, :notes
  end
end
