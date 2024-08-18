module UserCalculations
  def total_miles = runs.pluck(:distance).sum

  def total_duration = runs.where.not(duration: nil).pluck(:duration).sum

  def total_km = (total_miles * 1.609344).round(3)

  def runs_this_season(team) =
    runs.in_date_range(team.season_start_date..team.season_end_date)

  def miles_this_season(team) = runs_this_season(team).pluck(:distance).sum

  def long_runs_this_season(team)
    unless team.require_gender?
      long_run_distance = team.settings(:runs).long_run_distance_neutral
    else
      long_run_distance =
        if male?
          team.settings(:runs).long_run_distance_male
        else
          team.settings(:runs).long_run_distance_female
        end
    end

    runs_this_season(team).where('distance > ?', long_run_distance)
  end

  def total_long_runs_this_season(team) = long_runs_this_season(team).count
end
