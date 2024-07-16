module UserCalculations
  def total_miles = runs.pluck(:distance).sum

  def total_duration = runs.where.not(duration: nil).pluck(:duration).sum


  def total_km = (total_miles * 1.609344).round(3)

  def runs_this_season(team) =
    runs.in_date_range(team.season_start_date..team.season_end_date)

  def miles_this_season(team) = runs_this_season(team).pluck(:distance).sum
end
