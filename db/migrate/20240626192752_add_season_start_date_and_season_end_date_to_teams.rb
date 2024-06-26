class AddSeasonStartDateAndSeasonEndDateToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :season_start_date, :date
    add_column :teams, :season_end_date, :date
  end
end
