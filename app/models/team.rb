class Team < ApplicationRecord
  include TeamCalculations
  include TeamSettings

  belongs_to :owner, class_name: 'User'
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user
  has_many :join_requests, foreign_key: 'team_id', class_name: 'TeamJoinRequest'
  has_one_attached :photo

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

  def season_dates? = season_start_date.present? && season_end_date.present?

  def gender_requirement_met?(user)
    return true unless settings(:join_requirements).require_gender

    return true unless user.gender.blank?

    false
  end

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
