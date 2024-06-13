class AddDurationToRuns < ActiveRecord::Migration[7.1]
  def change
    add_column :runs, :duration, :interval, null: false
  end
end
