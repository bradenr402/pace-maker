class AddLongRunGoalToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :long_run_goal, :integer
  end
end
