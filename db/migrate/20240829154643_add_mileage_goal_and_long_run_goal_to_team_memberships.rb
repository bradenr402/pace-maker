class AddMileageGoalAndLongRunGoalToTeamMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :team_memberships, :mileage_goal, :integer
    add_column :team_memberships, :long_run_goal, :integer
  end
end
