class AddStravaAcceptedScopeToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :strava_accepted_scope, :string
  end
end
