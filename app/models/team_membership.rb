class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id,
            uniqueness: {
              scope: :team_id,
              message: 'is already a member of the team'
            }

  delegate :season_progress, to: :team

  def miles_completed_in_goal = user.miles_this_season(team)

  def miles_remaining_in_goal = mileage_goal - miles_completed_in_goal

  def long_runs_completed_in_goal = user.total_long_runs_this_season(team)

  def long_runs_remaining_in_goal = long_run_goal - long_runs_completed_in_goal

  def mileage_goal_progress
    return nil unless mileage_goal?

    progress = (miles_completed_in_goal / mileage_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def meeting_mileage_goal? = (mileage_goal_progress - season_progress).abs <= 5

  def ahead_of_mileage_goal? = mileage_goal_progress - season_progress > 5

  def behind_mileage_goal? = season_progress - mileage_goal_progress > 5

  def long_run_goal_progress
    return nil unless long_run_goal?

    progress = (long_runs_completed_in_goal / long_run_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def meeting_long_run_goal? =
    (long_run_goal_progress - season_progress).abs <= 5

  def ahead_of_long_run_goal? = long_run_goal_progress - season_progress > 5

  def behind_long_run_goal? = season_progress - long_run_goal_progress > 5
end
