module UserCalculations
  # Mileage calculations
  def total_miles = runs.sum(:distance).round(1)

  def total_km = (total_miles * 1.609344).round(1)

  def miles_this_season(team) = runs_this_season(team).sum(:distance).round(1)

  def miles_in_date_range(date_range) =
    runs_in_date_range(date_range).sum(:distance).round(1)

  # Duration calculations
  def total_duration = runs.where.not(duration: nil).sum(:duration)

  # Run calculations
  def runs_this_season(team) =
    runs.in_date_range(team.season_start_date..team.season_end_date)

  def runs_in_date_range(date_range) = runs.where(date: date_range)

  def runs_on_day(date) = runs.where(date:)

  # Long run calculations
  def long_runs_this_season(team) =
    runs.where(data: team.season_range, distance: team.long_run_distance_for_user(self)..Float::INFINITY)

  def total_long_runs_this_season(team) =
    runs.where(date: team.season_range, distance: team.long_run_distance_for_user(self)..Float::INFINITY).count

  def total_long_runs(team) =
    runs.where(distance: team.long_run_distance_for_user(self)..Float::INFINITY).count

  def long_runs_in_date_range(team, date_range) =
    runs.where(date: date_range, distance: team.long_run_distance_for_user(self)..Float::INFINITY)

  def total_long_runs_in_date_range(team, date_range) =
    runs.where(date: date_range, distance: team.long_run_distance_for_user(self)..Float::INFINITY).count

  # Streak calculations
  def current_streak(team = nil, current_date = Date.current)
    @all_runs ||= runs
    return { streak: 0, start_date: nil, end_date: nil } if @all_runs.empty?

    streak = 0
    start_date = nil
    end_date = nil

    loop do
      runs_on_date = @all_runs.where(date: current_date)
      required_distance = team&.streak_distance_for_user(self) || 0

      if runs_on_date.any? { |run| run.distance >= required_distance }
        end_date ||= current_date
        start_date = current_date
        streak += 1
      else
        break unless team&.exclude_date_from_streak?(current_date)
      end

      current_date = current_date.prev_day
    end

    { streak:, start_date:, end_date: }
  end

  def record_streak(team = nil)
    return { streak: 0, start_date: nil, end_date: nil } if runs.empty?

    run_dates = runs.order(:date).pluck(:date)
    oldest_date = run_dates.first
    newest_date = run_dates.last
    current_date = newest_date

    longest_streak = 0
    longest_start_date = nil
    longest_end_date = nil

    while current_date >= oldest_date
      streak_data = current_streak(team, current_date)
      streak = streak_data[:streak]

      if streak > longest_streak
        longest_streak = streak
        longest_start_date = streak_data[:start_date]
        longest_end_date = streak_data[:end_date]
      end

      current_date = (streak_data[:start_date] || current_date).prev_day
    end

    {
      streak: longest_streak,
      start_date: longest_start_date,
      end_date: longest_end_date
    }
  end
end
