module UserCalculations
  # Mileage calculations
  def total_miles
    Rails.cache.fetch("#{cache_key_with_version}/total_miles") do
      runs.sum(:distance).round(1)
    end
  end

  def total_km
    Rails.cache.fetch("#{cache_key_with_version}/total_km") do
      (total_miles * 1.609344).round(1)
    end
  end

  def miles_this_season(team)
    Rails.cache.fetch("#{cache_key_with_version}/miles_this_season/#{team.id}") do
      runs_this_season(team).sum(:distance).round(1)
    end
  end

  def miles_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/miles_in_date_range/#{date_range.hash}") do
      runs_in_date_range(date_range).sum(:distance).round(1)
    end
  end

  # Duration calculations
  def total_duration
    Rails.cache.fetch("#{cache_key_with_version}/total_duration") do
      runs.where.not(duration: nil).sum(:duration)
    end
  end

  # Run calculations
  def runs_this_season(team)
    Rails.cache.fetch("#{cache_key_with_version}/runs_this_season/#{team.id}") do
      runs.in_date_range(team.season_start_date..team.season_end_date)
    end
  end

  def runs_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/runs_in_date_range/#{date_range.hash}") do
      runs.where(date: date_range)
    end
  end

  def runs_on_day(date)
    Rails.cache.fetch("#{cache_key_with_version}/runs_on_day/#{date}") do
      runs.where(date:)
    end
  end

  # Long run calculations
  def total_long_runs(team)
    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs/#{team.id}") do
      runs.where(
        distance: team.long_run_distance_for_user(self)..Float::INFINITY
      ).count
    end
  end

  def long_runs_this_season(team)
    Rails.cache.fetch("#{cache_key_with_version}/long_runs_this_season/#{team.id}") do
      runs.where(
        data: team.season_range,
        distance: team.long_run_distance_for_user(self)..Float::INFINITY
      )
    end
  end

  def total_long_runs_this_season(team)
    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs_this_season/#{team.id}") do
      runs.where(
        date: team.season_range,
        distance: team.long_run_distance_for_user(self)..Float::INFINITY
      ).count
    end
  end

  def long_runs_in_date_range(team, date_range)
    Rails.cache.fetch("#{cache_key_with_version}/long_runs_in_date_range/#{team.id}/#{date_range.hash}") do
      runs.where(
        date: date_range,
        distance: team.long_run_distance_for_user(self)..Float::INFINITY
      )
    end
  end

  def total_long_runs_in_date_range(team, date_range)
    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs_in_date_range/#{team.id}/#{date_range.hash}") do
      runs.where(
        date: date_range,
        distance: team.long_run_distance_for_user(self)..Float::INFINITY
      ).count
    end
  end

  # Streak calculations
  def current_streak(team = nil, current_date = Date.current)
    Rails.cache.fetch("#{cache_key_with_version}/current_streak/#{team&.id}/#{current_date}") do
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
          break unless current_date.today? || team&.exclude_date_from_streak?(current_date)
        end

        current_date = current_date.prev_day
      end

      { streak:, start_date:, end_date: }
    end
  end

  def record_streak(team = nil)
    Rails.cache.fetch("#{cache_key_with_version}/record_streak/#{team&.id}") do
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
end
