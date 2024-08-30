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

  def mileage_goal_complete? = mileage_goal_progress >= 100

  def long_run_goal_progress
    return nil unless long_run_goal?

    progress = (long_runs_completed_in_goal / long_run_goal.to_f) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def meeting_long_run_goal? =
    (long_run_goal_progress - season_progress).abs <= 5

  def ahead_of_long_run_goal? = long_run_goal_progress - season_progress > 5

  def behind_long_run_goal? = season_progress - long_run_goal_progress > 5

  def long_run_goal_complete? = long_run_goal_progress >= 100

  def mileage_goal_progress_message(current_user)
    possessive = user == current_user ? 'your' : user.gender_possessive
    met_goal = user == current_user ? "you've" : "#{user.first_name} has"
    personal = user == current_user ? 'your' : 'personal'
    season_state = user == current_user ? "You're" : "#{member.first_name} is"
    team_state = user == current_user ? "You're" : 'Your team is'

    if mileage_goal_complete?
      "#{season_state} met #{possessive} mileage goal! #{team_state} #{season_progress}% through the season, and #{met_goal} met #{mileage_goal_progress}% of #{possessive} long run goal."
    elsif meeting_mileage_goal?
      "#{season_state} on track! #{team_state} #{season_progress}% through the season, and #{met_goal} met #{mileage_goal_progress}% of #{possessive} personal mileage goal."
    elsif ahead_of_mileage_goal?
      "#{season_state} advancing! #{team_state} #{season_progress}% through the season, and #{met_goal} already met #{mileage_goal_progress}% of #{possessive} personal mileage goal."
    else
      "#{season_state} falling behind! #{team_state} #{season_progress}% through the season, but #{met_goal} only met #{mileage_goal_progress}% of #{possessive} personal mileage goal."
    end
  end

  def long_run_goal_progress_message(current_user)
    possessive = user == current_user ? 'your' : user.gender_possessive
    met_goal = user == current_user ? "you've" : "#{user.first_name} has"
    season_state = user == current_user ? "You're" : "#{user.first_name} is"
    team_state = user == current_user ? "You're" : 'Your team is'

    if long_run_goal_complete?
      "#{season_state} met #{possessive} long run goal! #{team_state} #{season_progress}% through the season, and #{met_goal} met #{long_run_goal_progress}% of #{possessive} mileage goal."
    elsif meeting_long_run_goal?
      "#{season_state} on track! #{team_state} #{season_progress}% through the season, and #{met_goal} met #{long_run_goal_progress}% of #{possessive} personal long run goal."
    elsif ahead_of_long_run_goal?
      "#{season_state} advancing! #{team_state} #{season_progress}% through the season, and #{met_goal} already met #{long_run_goal_progress}% of #{possessive} personal long run goal."
    else
      "#{season_state} falling behind! #{team_state} #{season_progress}% through the season, but #{met_goal} only met #{long_run_goal_progress}% of #{possessive} personal long run goal."
    end
  end
end
