class AddStravaFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :strava_uid, :string
    add_column :users, :strava_access_token, :string
    add_column :users, :strava_refresh_token, :string
    add_column :users, :strava_token_expires_at, :datetime
  end
end
