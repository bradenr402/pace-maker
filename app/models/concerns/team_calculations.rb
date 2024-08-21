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
    return nil unless self.season_dates?

    season_duration = season_end_date - season_start_date
    days_since_start = Date.today - season_start_date

    progress = (days_since_start / season_duration.to_f) * 100.0

    progress.clamp(0.0, 100.0).round(2) # Ensures progress stays between 0% and 100%
  end

  def days_remaining_in_season = (season_end_date - Date.today).to_i

  def mileage_goal_progress
    return nil unless mileage_goal.present?

    progress = (total_miles_in_season / mileage_goal) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def miles_remaining_in_goal = (mileage_goal - total_miles_in_season).to_i
end
