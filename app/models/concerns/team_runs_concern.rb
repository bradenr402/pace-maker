module TeamRunsConcern
  extend ActiveSupport::Concern

  def long_run_distance_for_user(user)
    return long_run_distance_neutral unless require_gender?

    user.male? ? long_run_distance_male : long_run_distance_female
  end

  def streak_distance_for_user(user)
    return streak_distance_neutral unless require_gender?

    user.male? ? streak_distance_male : streak_distance_female
  end

  def recent_runs
    Rails.cache.fetch(members.cache_key_with_version) do
      Run
        .includes(:user)
        .where(users: { id: members.pluck(:id) })
        .order(date: :desc)
        .first(15)
    end
  end

  def recent_long_runs
    Rails.cache.fetch([members.cache_key_with_version, 'long_runs', Date.current]) do
      Run
        .includes(:user)
        .where(users: { id: members.pluck(:id) })
        .where(
          'CAST(distance AS numeric) >= CAST(CASE
          WHEN users.gender = ? THEN ?
          WHEN users.gender = ? THEN ?
          ELSE ? END AS numeric)',
          'male',
          long_run_distance_male,
          'female',
          long_run_distance_female,
          long_run_distance_neutral
        )
        .order(date: :desc)
        .first(15)
    end
  end

  def streak_runs
    Rails.cache.fetch([members.cache_key_with_version, 'streak_runs', Date.current]) do
      Run
        .includes(:user)
        .where(users: { id: members.pluck(:id) })
        .where('date >= ?', Date.current.yesterday)
        .where(
          'CAST(distance AS numeric) >= CAST(CASE
          WHEN users.gender = ? THEN ?
          WHEN users.gender = ? THEN ?
          ELSE ? END AS numeric)',
          'male',
          streak_distance_male,
          'female',
          streak_distance_female,
          streak_distance_neutral
        )
        .order(date: :desc)
    end
  end

  def featured_runs = (recent_long_runs | streak_runs).sort_by(&:date).reverse

  def long_runs_in_date_range(range)
    Rails.cache.fetch([members.cache_key_with_version, 'long_runs_range', range.hash]) do
      Run
        .includes(:user)
        .where(users: { id: members.pluck(:id) })
        .in_date_range(range)
        .where(
          'CAST(distance AS numeric) >= CAST(CASE
          WHEN users.gender = ? THEN ?
          WHEN users.gender = ? THEN ?
          ELSE ? END AS numeric)',
          'male',
          long_run_distance_male,
          'female',
          long_run_distance_female,
          long_run_distance_neutral
        )
    end
  end
end
