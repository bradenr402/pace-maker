class RemoveTimeFromRuns < ActiveRecord::Migration[7.1]
  def change
    remove_column :runs, :time, :time
  end
end
