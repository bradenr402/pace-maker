class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validate :not_already_a_member

  def not_already_a_member
    
  end
end
