module UserCalculations
  def total_miles = runs.sum(:distance)

  def total_duration = runs.where.not(duration: nil).sum(:duration)

  def total_km = (total_miles * 1.609344).round(3)

  def runs_this_season(team) =
    runs.in_date_range(team.season_start_date..team.season_end_date)

  def miles_this_season(team) = runs_this_season(team).sum(:distance)

  def long_runs_this_season(team)
    unless team.require_gender?
      long_run_distance = team.long_run_distance_neutral
    else
      long_run_distance =
        (male? ? team.long_run_distance_male : team.long_run_distance_female)
    end

    runs_this_season(team).where('distance > ?', long_run_distance)
  end

  def total_long_runs_this_season(team) = long_runs_this_season(team).count

  def total_long_runs(team)
    unless team.require_gender?
      long_run_distance = team.long_run_distance_neutral
    else
      long_run_distance =
        (male? ? team.long_run_distance_male : team.long_run_distance_female)
    end

    runs.where('distance > ?', long_run_distance).count
  end

  def miles_in_date_range(date_range) =
    runs_in_date_range(date_range).sum(:distance)

  def long_runs_in_date_range(team, date_range)
    unless team.require_gender?
      long_run_distance = team.long_run_distance_neutral
    else
      long_run_distance =
        (male? ? team.long_run_distance_male : team.long_run_distance_female)
    end

    runs_in_date_range(date_range).where(
      'distance > ?',
      long_run_distance
    ).count
  end

  def total_long_runs_in_date_range(team, date_range) =
    long_runs_in_date_range(team, date_range).count

  def runs_valid_for_streak(team)
    settings = team.settings(:streaks)
    required_distance =
      if team.require_gender?
        if male?
          settings.streak_distance_male.to_i
        else
          settings.streak_distance_female.to_i
        end
      else
        settings.streak_distance_neutral.to_i
      end

    runs.where('distance >= ?', required_distance)
  end

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

    most_recent_run = filtered_runs.first
    unless (most_recent_run.saturday? && team.exclude_saturday_from_streak?) ||
             (most_recent_run.sunday? && team.exclude_sunday_from_streak?) ||
             (most_recent_run == Date.current - 1.day) ||
             (most_recent_run == Date.current)
      return { streak: 0, start_date: nil, end_date: most_recent_run }
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
    if streak == 1
      return { streak: 1, start_date: filtered_runs.first, end_date: nil }
    end

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
    if longest_streak == 1
      return { streak: 1, start_date: filtered_runs.first, end_date: nil }
    end

    {
      streak: longest_streak,
      start_date: longest_start_date,
      end_date: longest_end_date
    }
  end
end
