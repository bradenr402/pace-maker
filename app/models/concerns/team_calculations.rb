module TeamCalculations
  def total_miles_in_season =
    Run
      .joins(user: :teams)
      .where(teams: { id: })
      .in_date_range(season_start_date..season_end_date)
      .sum(:distance)

  def runs_in_season =
    Run
      .joins(:user)
      .where(users: { id: members.pluck(:id) })
      .in_date_range(date: season_start_date..season_end_date)

  def total_long_runs_in_season =
    members.sum { |member| member.total_long_runs_this_season(self) }

  def total_miles = members.sum { |member| member.total_miles }

  def total_long_runs = members.sum { |member| member.total_long_runs(self) }

  def miles_in_date_range(date_range) =
    members.sum { |member| member.miles_in_date_range(date_range) }

  def total_long_runs_in_date_range(date_range) =
    members.sum { |member| member.long_runs_in_date_range(self, date_range) }

  def season_progress
    return nil unless season_dates?

    season_duration = season_end_date - season_start_date
    days_since_start = Date.today - season_start_date

    progress = (days_since_start / season_duration.to_f) * 100.0

    progress.clamp(0.0, 100.0).round(2) # Ensures progress stays between 0% and 100%
  end

  def days_remaining_in_season = (season_end_date - Date.today).to_i

  def mileage_goal_progress
    return nil unless mileage_goal?

    progress = (total_miles_in_season / mileage_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def miles_remaining_in_goal = mileage_goal - total_miles_in_season

  def meeting_mileage_goal? = (mileage_goal_progress - season_progress).abs <= 5

  def ahead_of_mileage_goal? = mileage_goal_progress - season_progress > 5

  def behind_mileage_goal? = season_progress - mileage_goal_progress > 5

  def long_run_goal_progress
    return nil unless long_run_goal?

    progress = (total_long_runs_in_season / long_run_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def long_runs_remaining_in_goal = long_run_goal - total_long_runs_in_season

  def meeting_long_run_goal? = (long_run_goal_progress - season_progress).abs <= 5

  def ahead_of_long_run_goal? = long_run_goal_progress - season_progress > 5

  def behind_long_run_goal? = season_progress - long_run_goal_progress > 5
end
