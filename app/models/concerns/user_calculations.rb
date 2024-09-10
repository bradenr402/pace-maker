module UserCalculations
  # Mileage calculations
  def total_miles = runs.sum(:distance)

  def total_km = (total_miles * 1.609344).round(3)

  def miles_this_season(team) = runs_this_season(team).sum(:distance)

  def miles_in_date_range(date_range) =
    runs_in_date_range(date_range).sum(:distance)

  # Duration calculations
  def total_duration = runs.where.not(duration: nil).sum(:duration)

  # Run calculations
  def runs_this_season(team) =
    runs.in_date_range(team.season_start_date..team.season_end_date)

  def runs_in_date_range(date_range) = runs.where(date: date_range)

  def runs_on_day(date) = runs.where(date:)

  def runs_valid_for_streak(team)
    required_distance = team.streak_distance_for_user(self)

    runs.where('distance >= ?', required_distance)
  end

  # Long run calculations
  def long_runs_this_season(team)
    long_run_distance = team.long_run_distance_for_user(self)

    runs_this_season(team).where('distance > ?', long_run_distance)
  end

  def total_long_runs_this_season(team) = long_runs_this_season(team).count

  def total_long_runs(team) =
    runs.where('distance >= ?', team.long_run_distance_for_user(self)).count

  def long_runs_in_date_range(team, date_range) =
    runs_in_date_range(date_range).where(
      'distance >= ?',
      team.long_run_distance_for_user(self)
    )

  def total_long_runs_in_date_range(team, date_range) =
    long_runs_in_date_range(team, date_range).count

  # Streak calculations
  def current_streak(team)
    filtered_runs =
      runs_valid_for_streak(team)
      .order(date: :desc)
      .distinct
      .pluck(:date)
      .map(&:to_date)

    # Return a streak of 0 if there are no qualifying runs
    return { streak: 0, start_date: nil, end_date: nil } if filtered_runs.empty?

    # Initialize streak count and start date
    streak = 1
    start_date = nil

    # Return a streak of 0 if the streak has been broken
    # (i.e. the most recent run is not the previous day
    # or the previous day is a Saturday or Sunday and the team excludes Saturdays and Sundays from streaks)
    most_recent_run = filtered_runs.first
    unless (most_recent_run.saturday? && team.exclude_saturday_from_streak?) ||
           (most_recent_run.sunday? && team.exclude_sunday_from_streak?) ||
           (most_recent_run == Date.current - 1.day) ||
           (most_recent_run == Date.current)
      return { streak: 0, start_date: nil, end_date: nil }
    end

    filtered_runs.each_cons(2) do |current_date, previous_date|
      if current_date == previous_date + 1.day
        streak += 1
        start_date = previous_date
      elsif (current_date - 1.day).saturday? &&
            team.exclude_saturday_from_streak?
        next
      elsif (current_date - 1.day).sunday? && team.exclude_sunday_from_streak?
        next
      else
        break
      end
    end

    # Return most recent run date if current streak is 1
    return { streak: 1, start_date: filtered_runs.first, end_date: nil } if streak == 1

    { streak:, start_date:, end_date: filtered_runs.first }
  end

  def longest_streak(team)
    filtered_runs =
      runs_valid_for_streak(team)
      .order(date: :desc)
      .distinct
      .pluck(:date)
      .map(&:to_date)

    # Return a streak of 0 if there are no qualifying runs
    return { streak: 0, start_date: nil, end_date: nil } if filtered_runs.empty?

    # Initialize streak counts, start dates, and end dates
    longest_streak = 1
    longest_start_date = nil
    longest_end_date = nil

    temp_streak = 1
    temp_start_date = nil
    temp_end_date = nil

    filtered_runs.each_cons(2) do |current_date, previous_date|
      if current_date == previous_date + 1.day
        temp_streak += 1
        temp_start_date = previous_date
        temp_end_date ||= current_date
      elsif (current_date - 1.day).saturday? &&
            team.exclude_saturday_from_streak?
        next
      elsif (current_date - 1.day).sunday? && team.exclude_sunday_from_streak?
        next
      else
        if temp_streak > longest_streak
          longest_streak = temp_streak
          longest_start_date = temp_start_date
          longest_end_date = temp_end_date
        end
        temp_streak = 1
        temp_start_date = nil
        temp_end_date = nil
        next
      end
    end

    # Return most recent run date if longest streak is 1
    return { streak: 1, start_date: filtered_runs.first, end_date: nil } if longest_streak == 1

    {
      streak: longest_streak,
      start_date: longest_start_date,
      end_date: longest_end_date
    }
  end
end
