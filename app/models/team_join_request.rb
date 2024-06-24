class TeamJoinRequest < ApplicationRecord
  belongs_to :user
  belongs_to :team

  enum :status, %i[pending approved rejected]

  validates :status, inclusion: { in: TeamJoinRequest.statuses.keys }
  validates :user_id, uniqueness: { scope: :team_id, message: 'has already sent a join request' }
end
