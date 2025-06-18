class AddIncludedInStatsToTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :team_memberships, :included_in_stats, :boolean, default: true, null: false
  end
end
