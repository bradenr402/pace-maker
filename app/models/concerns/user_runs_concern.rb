module UserRunsConcern
  extend ActiveSupport::Concern

  def runs_in_date_range(range) = runs.in_date_range(range)

  def runs_today = runs.today

  def run_on_day?(date) = runs.where(date: date.all_day).exists?

  def long_run_on_day?(date, team) =
    runs.where(date: date.all_day).any? { |run| run.long_run_for_team?(team) }
end
