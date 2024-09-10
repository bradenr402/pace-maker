module TeamCalculations
  # Season-related calculations
  def season_progress
    return nil unless season_dates?

    season_duration = season_end_date - season_start_date
    days_since_start = Date.today - season_start_date

    progress = (days_since_start / season_duration.to_f) * 100.0

    progress.clamp(0.0, 100.0).round(2) # Ensures progress stays between 0% and 100%
  end

  def days_remaining_in_season = (season_end_date - Date.today).to_i

  # Mileage calculations
  def total_miles_in_season =
    members.flat_map { |member| member.runs_this_season(self) }.sum(&:distance)

  def total_miles = members.sum(&:total_miles)

  def total_miles_on_day(date) =
    members.sum { |member| member.runs_on_day(date).sum(&:distance) }

  def miles_in_date_range(date_range) =
    members.sum { |member| member.miles_in_date_range(date_range) }

  # Run calculations
  def runs_in_season =
    members.flat_map { |member| member.runs_this_season(self) }

  def runs_in_date_range(date_range) =
    members.flat_map { |member| member.runs_in_date_range(date_range) }

  # Long run calculations
  def long_runs_in_season =
    members.flat_map { |member| member.long_runs_this_season(self) }

  def total_long_runs_in_season =
    members.sum { |member| member.total_long_runs_this_season(self) }

  def total_long_runs = members.sum { |member| member.total_long_runs(self) }

  def long_runs_in_date_range(date_range) =
    members.flat_map do |member|
      member.long_runs_in_date_range(self, date_range)
    end

  def total_long_runs_in_date_range(date_range) =
    members.sum { |member| member.long_runs_in_date_range(self, date_range) }

  def long_runs_on_day(date) =
    members.flat_map do |member|
      member
        .runs
        .where(date:)
        .select { |run| run.distance >= long_run_distance_for_user(member) }
    end

  def total_long_runs_on_day(date) = long_runs_on_day(date).count

  # Mileage goal progress
  def mileage_goal_progress
    return nil unless mileage_goal?

    progress = (total_miles_in_season / mileage_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def miles_remaining_in_goal = mileage_goal - total_miles_in_season

  def meeting_mileage_goal? = (mileage_goal_progress - season_progress).abs <= 5

  def ahead_of_mileage_goal? = mileage_goal_progress - season_progress > 5

  def behind_mileage_goal? = season_progress - mileage_goal_progress > 5

  def mileage_goal_complete? = mileage_goal_progress >= 100

  # Long run goal progress
  def long_run_goal_progress
    return nil unless long_run_goal?

    progress = (total_long_runs_in_season / long_run_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def long_runs_remaining_in_goal = long_run_goal - total_long_runs_in_season

  def meeting_long_run_goal? =
    (long_run_goal_progress - season_progress).abs <= 5

  def ahead_of_long_run_goal? = long_run_goal_progress - season_progress > 5

  def behind_long_run_goal? = season_progress - long_run_goal_progress > 5

  def long_run_goal_complete? = long_run_goal_progress >= 100

  # Progress messages
  def mileage_goal_progress_message
    if mileage_goal_complete?
      "Your team met its mileage goal! You're #{season_progress}% through the season, and you've met #{mileage_goal_progress}% of your mileage goal."
    elsif meeting_mileage_goal?
      "Your team is on track! You're #{season_progress}% through the season, and you've met #{mileage_goal_progress}% of your mileage goal."
    elsif ahead_of_mileage_goal?
      "Your team is advancing! You're #{season_progress}% through the season, and you've already met #{mileage_goal_progress}% of your mileage goal."
    else
      "Your team is falling behind! You're #{season_progress}% through the season, but you've only met #{mileage_goal_progress}% of your mileage goal."
    end
  end

  def long_run_goal_progress_message
    if long_run_goal_complete?
      "Your team met its long run goal! You're #{season_progress}% through the season, and you've met #{long_run_goal_progress}% of your long run goal."
    elsif meeting_long_run_goal?
      "Your team is on track! You're #{season_progress}% through the season, and you've met #{long_run_goal_progress}% of your long run goal."
    elsif ahead_of_long_run_goal?
      "Your team is advancing! You're #{season_progress}% through the season, and you've already met #{long_run_goal_progress}% of your long run goal."
    else
      "Your team is falling behind! You're #{season_progress}% through the season, but you've only met #{long_run_goal_progress}% of your long run goal."
    end
  end
end
