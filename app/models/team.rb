class Team < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :team_memberships
  has_many :members, through: :team_memberships, source: :user
  has_many :team_join_requests

  validates :name, presence: true
  validates :owner, presence: true

  def total_miles = Run.joins(user: :teams).where(teams: { id: }).sum(:distance)
end
