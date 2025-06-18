class AddAllowedToEditGoalsToTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :team_memberships, :allowed_to_edit_goals, :boolean, default: true, null: false
  end
end
