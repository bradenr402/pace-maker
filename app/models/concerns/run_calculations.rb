module RunCalculations
  def hours = (duration / 3600).to_i

  def minutes = ((duration % 3600) / 60).to_i

  def seconds = (duration % 60).to_i

  def distance_km = (distance * 1.609344).round(1)

  def pace
    return nil if distance.zero?

    (duration / distance).round
  end

  alias pace_per_mile pace

  def pace_per_km
    return nil if distance.zero?

    (duration / distance_km).round
  end

  def streak_value(team = nil)
    streak_data = user.current_streak(team)
    streak_value = streak_data[:streak]
    streak_end_date = streak_data[:end_date]

    return nil unless streak_value >= 2

    if (date.today? && streak_end_date.today?) || (date.yesterday? && streak_end_date.yesterday?)
      streak_value
    elsif date.yesterday? && streak_end_date.today?
      streak_value - 1
    end
  end
end
