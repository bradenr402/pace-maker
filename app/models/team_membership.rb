class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validate :not_already_a_member

  def not_already_a_member
    errors.add :user, 'You are already on this team.' if user.member_of?(self)
  end
end
