module UserCalculations
  # Mileage calculations
  def total_miles
    Rails.cache.fetch("#{cache_key_with_version}/total_miles/#{runs.maximum(:updated_at)}") do
      runs.sum(:distance).round(1)
    end
  end

  def total_km
    Rails.cache.fetch("#{cache_key_with_version}/total_km/#{total_miles}") do
      (total_miles * 1.609344).round(1)
    end
  end

  def miles_this_season(team)
    Rails.cache.fetch("#{cache_key_with_version}/miles_this_season/#{team.id}/#{total_miles}") do
      runs_this_season(team).sum(:distance).round(1)
    end
  end

  def miles_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/miles_in_date_range/#{date_range.hash}/#{total_miles}") do
      runs_in_date_range(date_range).sum(:distance).round(1)
    end
  end

  # Duration calculations
  def total_duration
    Rails.cache.fetch("#{cache_key_with_version}/total_duration/#{runs.maximum(:updated_at)}") do
      runs.where.not(duration: nil).sum(:duration)
    end
  end

  # Run calculations
  def runs_this_season(team)
    Rails.cache.fetch("#{cache_key_with_version}/runs_this_season/#{team.id}/#{runs.maximum(:updated_at)}") do
      runs.in_date_range(team.season_start_date..team.season_end_date)
    end
  end

  def runs_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/runs_in_date_range/#{date_range.hash}/#{runs.maximum(:updated_at)}") do
      runs.where(date: date_range)
    end
  end

  def runs_on_day(date)
    Rails.cache.fetch("#{cache_key_with_version}/runs_on_day/#{date}/#{runs.maximum(:updated_at)}") do
      runs.where(date:)
    end
  end

  # Long run calculations
  def long_runs(team)
    required_distance = team.long_run_distance_for_user(self)

    Rails.cache.fetch("#{cache_key_with_version}/long_runs/#{required_distance}/#{runs.maximum(:updated_at)}") do
      runs.where(distance: required_distance..Float::INFINITY)
    end
  end

  def total_long_runs(team)
    required_distance = team.long_run_distance_for_user(self)

    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs/#{required_distance}/#{long_runs(team).maximum(:updated_at)}") do
      runs.where(
        distance: required_distance..Float::INFINITY
      ).count
    end
  end

  def long_runs_this_season(team)
    required_distance = team.long_run_distance_for_user(self)

    Rails.cache.fetch("#{cache_key_with_version}/long_runs_this_season/#{required_distance}/#{long_runs(team).maximum(:updated_at)}") do
      runs.where(
        date: team.season_range,
        distance: required_distance..Float::INFINITY
      )
    end
  end

  def total_long_runs_this_season(team)
    required_distance = team.long_run_distance_for_user(self)

    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs_this_season/#{required_distance}/#{long_runs(team).maximum(:updated_at)}") do
      runs.where(
        date: team.season_range,
        distance: required_distance..Float::INFINITY
      ).count
    end
  end

  def long_runs_in_date_range(team, date_range)
    required_distance = team.long_run_distance_for_user(self)

    Rails.cache.fetch("#{cache_key_with_version}/long_runs_in_date_range/#{required_distance}/#{date_range.hash}/#{long_runs(team).maximum(:updated_at)}") do
      runs.where(
        date: date_range,
        distance: required_distance..Float::INFINITY
      )
    end
  end

  def total_long_runs_in_date_range(team, date_range)
    required_distance = team.long_run_distance_for_user(self)

    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs_in_date_range/#{required_distance}/#{date_range.hash}/#{long_runs(team).maximum(:updated_at)}") do
      runs.where(
        date: date_range,
        distance: required_distance..Float::INFINITY
      ).count
    end
  end

  # Streak calculations
  def streak_on_date(team = nil, starting_date = Date.current)
    min_distance = min_distance team

    expires_in_seconds = Time.now.end_of_day - Time.now
    Rails.cache.fetch(
      "#{cache_key_with_version}/streak_on_date/#{starting_date}/#{min_distance}",
      expires_in: expires_in_seconds
    ) do
      dates_with_runs = runs.where('distance >= ? AND date <= ?', min_distance, starting_date)
                            .order(date: :desc).pluck(:date).uniq

      run_today_or_yesterday = dates_with_runs.first == starting_date || dates_with_runs.first == starting_date - 1.day

      return { streak: 0, start_date: nil, end_date: nil } unless dates_with_runs.present? || run_today_or_yesterday

      streak, start_date, end_date =
        if run_today_or_yesterday
          [1, dates_with_runs.first, dates_with_runs.first]
        else
          [0, nil, nil]
        end

      return { streak:, start_date:, end_date: } unless run_today_or_yesterday && dates_with_runs.size > 1

      dates_with_runs.each_cons(2) do |curr_date, prev_date|
        reset_if_broken =
          curr_date != starting_date && [curr_date, prev_date].any? { team&.include_date_in_streak?(_1) }

        if prev_date == curr_date - 1.day
          streak += 1
          start_date = prev_date
          end_date ||= curr_date
        elsif reset_if_broken
          break
        end
      end

      { streak:, start_date:, end_date: }
    end
  end

  def current_streak(team = nil) = streak_on_date(team, Date.current)

  def record_streak(team = nil)
    min_distance = min_distance team

    # Cache expiration based on the most recent `updated_at` of user's runs
    last_updated_at = runs.maximum(:updated_at)
    Rails.cache.fetch("#{cache_key_with_version}/record_streak/#{last_updated_at}") do
      dates_with_runs = runs.where('distance >= ?', min_distance)
                            .order(date: :desc).pluck(:date).uniq

      return { streak: 0, start_date: nil, end_date: nil } unless dates_with_runs.present?

      longest_streak = 0
      longest_start_date = nil
      longest_end_date = nil

      dates_with_runs.each_cons(2) do |curr_date, _prev_date|
        streak_data = streak_on_date(team, curr_date)
        streak = streak_data[:streak]
        start_date = streak_data[:start_date]
        end_date = streak_data[:end_date]

        next unless streak > longest_streak

        longest_streak = streak
        longest_start_date = start_date
        longest_end_date = end_date
      end

      { streak: longest_streak, start_date: longest_start_date, end_date: longest_end_date }
    end
  end

  private

  def min_distance(team) = team&.streak_distance_for_user(self) || 0
end
