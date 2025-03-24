module UserRunsConcern
  extend ActiveSupport::Concern

  def runs_in_date_range(range) = runs.in_date_range(range)

  def runs_today = runs.today

  def runs_today? = runs.today.any?

  def run_on_day?(date) = runs.where(date: date.all_day).exists?

  def long_run_on_day?(date, team) =
    runs.where(date: date.all_day).any? { |run| run.long_run_for_team?(team) }

  def strava_runs = runs.where.not(strava_id: nil)

  def farthest_run = runs.order(distance: :desc).limit(1).take

  def longest_run = runs.where.not(duration: nil).order(duration: :desc).limit(1).take

  def fastest_run
    runs.where.not(duration: nil).where.not(duration: 0)
        .order(Arel.sql('distance / NULLIF(EXTRACT(EPOCH FROM duration), 0) DESC'))
        .limit(1)
        .take
  end
end
