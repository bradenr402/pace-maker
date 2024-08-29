class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id,
            uniqueness: {
              scope: :team_id,
              message: 'is already a member of the team'
            }

  delegate :season_progress, to: :team

  # TODO: remove this later
  def mileage_goal? = true

  # TODO: remove this later
  def mileage_goal = 100

  # TODO: implement this
  def miles_completed = 42

  # TODO: implement this
  def mileage_goal_progress = 42

  # TODO: implement this
  def miles_remaining_in_goal = mileage_goal - miles_completed

  # TODO: implement this
  def meeting_goal? = true

  # TODO: implement this
  def ahead_of_goal? = false

  # TODO: implement this
  def behind_goal? = false
end
