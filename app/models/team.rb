class Team < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user
  # has_many :team_join_requests
  has_many :join_requests, foreign_key: 'team_id', class_name: 'TeamJoinRequest'

  validates :name, presence: true
  validates :owner, presence: true
  validates :description, length: { maximum: 500 }
  validates :season_end_date,
            comparison: {
              greater_than: :season_start_date
            },
            if: -> { season_start_date.present? && season_end_date.present? }
  validate :season_dates_presence
  validates :mileage_goal,
            numericality: {
              greater_than_or_equal_to: 0
            },
            if: -> { mileage_goal.present? }

  scope :not_included_in, ->(team_ids) { where.not(id: team_ids) }

  def total_miles =
    Run
      .joins(user: :teams)
      .where(teams: { id: })
      .where(date: season_start_date..season_end_date)
      .pluck(:distance)
      .sum

  def runs_in_season =
    Run
      .joins(:user)
      .where(users: { id: members.pluck(:id) })
      .where(date: season_start_date..season_end_date)
      .order(date: :desc)

  def season_progress
    return nil unless season_start_date.present? && season_end_date.present?

    season_duration = season_end_date - season_start_date
    days_since_start = Date.today - season_start_date

    progress = (days_since_start / season_duration.to_f) * 100.0

    progress.clamp(0.0, 100.0).round(2) # Ensures progress stays between 0% and 100%
  end

  def mileage_goal_progress
    return nil unless mileage_goal.present?

    progress = (total_miles / mileage_goal) * 100.0

    [progress, 0.0].max.round(2) # Ensures progess stays above 0%
  end

  def season_dates? = season_start_date.present? && season_end_date.present?

  # def join_requests = team_join_requests

  private

  def season_dates_presence
    if season_start_date.present? && season_end_date.blank? ||
         season_start_date.blank? && season_end_date.present?
      errors.add(
        :base,
        'Season start date and season end date must both be present or both be absent'
      )
    end
  end
end
