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
    user_is_current = user == current_user

    user_status, meeting_goal_status =
      if mileage_goal_complete?
        if user_is_current
          ['You\'ve met your mileage goal', 'and you\'ve completed']
        else
          [
            "#{user.first_name} met #{user.gender_possessive} mileage goal ",
            "and #{user.first_name} has completed"
          ]
        end
      elsif meeting_mileage_goal?
        if user_is_current
          ['You\'re on track', 'and you\'ve completed']
        else
          [
            "#{user.first_name} is on track",
            "and #{user.first_name} has completed"
          ]
        end
      elsif ahead_of_mileage_goal?
        if user_is_current
          ['You\'re advancing', 'and you\'ve already completed']
        else
          [
            "#{user.first_name} is advancing",
            "and #{user.first_name} has already completed"
          ]
        end
      elsif user_is_current
        ['You\'re falling behind', 'but you\'ve only completed']
      else
        [
          "#{user.first_name} is falling behind",
          "but #{user.first_name} has only completed"
        ]
      end

    team_state = user_is_current ? "You're" : 'Your team is'
    possessive = user_is_current ? 'your' : user.gender_possessive

    "#{user_status}! #{team_state} #{season_progress}% through the season, #{meeting_goal_status} #{mileage_goal_progress}% of #{possessive} personal mileage goal."
  end

  def long_run_goal_progress_message(current_user)
    user_is_current = user == current_user

    user_status, meeting_goal_status =
      if long_run_goal_complete?
        if user_is_current
          ['You\'ve met your long run goal', 'and you\'ve completed']
        else
          [
            "#{user.first_name} met #{user.gender_possessive} long run goal",
            "and #{user.first_name} has completed"
          ]
        end
      elsif meeting_long_run_goal?
        if user_is_current
          ['You\'re on track', 'and you\'ve completed']
        else
          [
            "#{user.first_name} is on track",
            "and #{user.first_name} has completed"
          ]
        end
      elsif ahead_of_long_run_goal?
        if user_is_current
          ['You\'re advancing', 'and you\'ve already completed']
        else
          [
            "#{user.first_name} is advancing",
            "and #{user.first_name} has already completed"
          ]
        end
      elsif user_is_current
        ['You\'re falling behind', 'but you\'ve only completed']
      else
        [
          "#{user.first_name} is falling behind",
          "but #{user.first_name} has only completed"
        ]
      end

    team_state = user_is_current ? "You're" : 'Your team is'
    possessive = user_is_current ? 'your' : user.gender_possessive

    "#{user_status}! #{team_state} #{season_progress}% through the season, #{meeting_goal_status} #{long_run_goal_progress}% of #{possessive} personal long run goal."
  end
end
