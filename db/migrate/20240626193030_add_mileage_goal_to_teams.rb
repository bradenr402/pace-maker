class AddMileageGoalToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :mileage_goal, :integer
  end
end
