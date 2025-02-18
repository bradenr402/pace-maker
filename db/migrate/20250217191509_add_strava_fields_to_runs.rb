class AddStravaFieldsToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :strava_id, :string
    add_column :runs, :strava_url, :string

    add_index :runs, :strava_id, unique: true
  end
end
