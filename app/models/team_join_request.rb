class TeamJoinRequest < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :team

  # Enums
  enum :status, %i[pending approved rejected canceled]

  # Validations
  validates :status, inclusion: { in: TeamJoinRequest.statuses.keys }
  validates :user_id,
            uniqueness: {
              scope: :team_id,
              message: 'has already sent a join request'
            }

  # Methods
  def blocked? = (request_number >= team.max_allowed_requests)

  def allowed?
    return false if blocked?
    return false if pending? || approved?
    return false if user.member_of?(team)
    return false if user.owns?(team)

    true
  end
end
