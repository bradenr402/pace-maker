module TeamCalculations
  # Season-related calculations
  def season_progress
    Rails.cache.fetch("#{cache_key_with_version}/season_progress/#{Date.current}") do
      return nil unless season_dates?

      season_duration = season_end_date - season_start_date
      days_since_start = Date.today - season_start_date

      progress = (days_since_start / season_duration.to_f) * 100.0

      progress.clamp(0.0, 100.0).round(2) # Ensures progress stays between 0% and 100%
    end
  end

  def days_remaining_in_season
    Rails.cache.fetch("#{cache_key_with_version}/days_remaining_in_season/#{Date.current}") do
      (season_end_date - Date.today).to_i
    end
  end

  # Mileage calculations
  def total_miles_in_season
    Rails.cache.fetch("#{cache_key_with_version}/total_miles_in_season/#{total_miles}/#{season_start_date}/#{season_end_date}/#{include_coach?}") do
      filtered_members.flat_map { |member| member.runs_this_season(self) }.sum(&:distance)
    end
  end

  def total_miles
    filtered_members.sum(&:total_miles)
  end

  def total_miles_on_day(date)
    Rails.cache.fetch("#{cache_key_with_version}/total_miles_on_day/#{date}/#{total_miles}/#{include_coach?}") do
      filtered_members.sum { |member| member.runs_on_day(date).sum(&:distance) }
    end
  end

  def miles_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/miles_in_date_range/#{date_range.hash}/#{total_miles}/#{include_coach?}") do
      filtered_members.sum { |member| member.miles_in_date_range(date_range) }
    end
  end

  # Run calculations
  def runs_in_season
    Rails.cache.fetch("#{cache_key_with_version}/runs_in_season/#{total_miles}/#{season_start_date}/#{season_end_date}/#{include_coach?}") do
      filtered_members.flat_map { |member| member.runs_this_season(self) }
    end
  end

  def runs_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/runs_in_date_range/#{date_range.hash}/#{total_miles}/#{include_coach?}") do
      filtered_members.flat_map { |member| member.runs_in_date_range(date_range) }
    end
  end

  # Long run calculations
  def long_runs_in_season
    Rails.cache.fetch("#{cache_key_with_version}/long_runs_in_season/#{total_miles}/#{season_start_date}/#{season_end_date}/#{include_coach?}") do
      filtered_members.flat_map { |member| member.long_runs_this_season(self) }
    end
  end

  def total_long_runs_in_season = long_runs_in_season.count

  def total_long_runs
    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs/#{total_miles}/#{include_coach?}") do
      filtered_members.sum { |member| member.total_long_runs(self) }
    end
  end

  def long_runs_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/long_runs_in_date_range/#{date_range.hash}/#{total_miles}/#{include_coach?}") do
      filtered_members.flat_map { |member| member.long_runs_in_date_range(self, date_range) }
    end
  end

  def total_long_runs_in_date_range(date_range)
    Rails.cache.fetch("#{cache_key_with_version}/total_long_runs_in_date_range/#{date_range.hash}/#{total_miles}") do
      long_runs_in_date_range(date_range).count
    end
  end

  def long_runs_on_day(date)
    Rails.cache.fetch("#{cache_key_with_version}/long_runs_on_day/#{date}/#{total_miles}/#{include_coach?}") do
      filtered_members.flat_map do |member|
        member
          .runs
          .where(date:)
          .select { |run| run.distance >= long_run_distance_for_user(member) }
      end
    end
  end

  def total_long_runs_on_day(date) = long_runs_on_day(date).count

  # Mileage goal progress
  def mileage_goal_progress
    Rails.cache.fetch("#{cache_key_with_version}/mileage_goal_progress/#{total_miles_in_season}") do
      return nil unless mileage_goal?

      progress = (total_miles_in_season / mileage_goal.to_f) * 100.0

      [progress, 0.0].max.round(2) # Ensures progess stays above 0%
    end
  end

  def miles_remaining_in_goal = mileage_goal - total_miles_in_season

  def meeting_mileage_goal? = (mileage_goal_progress - season_progress).abs <= 5

  def ahead_of_mileage_goal? = mileage_goal_progress - season_progress > 5

  def behind_mileage_goal? = season_progress - mileage_goal_progress > 5

  def mileage_goal_complete? = mileage_goal_progress >= 100

  # Long run goal progress
  def long_run_goal_progress
    Rails.cache.fetch("#{cache_key_with_version}/long_run_goal_progress/#{total_long_runs_in_season}") do
      return nil unless long_run_goal?

      progress = (total_long_runs_in_season / long_run_goal.to_f) * 100.0

      [progress, 0.0].max.round(2) # Ensures progess stays above 0%
    end
  end

  def long_runs_remaining_in_goal = long_run_goal - total_long_runs_in_season

  def meeting_long_run_goal? = (long_run_goal_progress - season_progress).abs <= 5

  def ahead_of_long_run_goal? = long_run_goal_progress - season_progress > 5

  def behind_long_run_goal? = season_progress - long_run_goal_progress > 5

  def long_run_goal_complete? = long_run_goal_progress >= 100

  # Progress messages
  def mileage_goal_progress_message
    team_status, meeting_goal_status =
      if mileage_goal_complete?
        ['met its mileage goal', 'and you\'ve completed']
      elsif meeting_mileage_goal?
        ['is on track', 'and you\'ve completed']
      elsif ahead_of_mileage_goal?
        ['is advancing', 'and you\'ve already completed']
      else
        ['is falling behind', 'but you\'ve only completed']
      end

    "Your team #{team_status}! You're #{season_progress}% through the season, #{meeting_goal_status} #{mileage_goal_progress}% of your mileage goal."
  end

  def long_run_goal_progress_message
    team_status, meeting_goal_status =
      if long_run_goal_complete?
        ['met its long run goal', 'and you\'ve completed']
      elsif meeting_long_run_goal?
        ['is on track', 'and you\'ve completed']
      elsif ahead_of_long_run_goal?
        ['is advancing', 'and you\'ve already completed']
      else
        ['is falling behind', 'but you\'ve only completed']
      end

    "Your team #{team_status}! You're #{season_progress}% through the season, #{meeting_goal_status} #{long_run_goal_progress}% of your long run goal."
  end
end
