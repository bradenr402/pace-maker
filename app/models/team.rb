class Team < ApplicationRecord
  include TeamCalculations
  include TeamSettings

  belongs_to :owner, class_name: 'User'
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user
  has_many :join_requests,
           foreign_key: 'team_id',
           class_name: 'TeamJoinRequest',
           dependent: :destroy
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

  def recent_runs =
    Run
      .joins(:user)
      .where(users: { id: members.pluck(:id) })
      .order(date: :desc)
      .first(15)

  def recent_long_runs
    runs =
      Run
        .joins(:user)
        .where(users: { id: members.pluck(:id) })
        .where('date >= ?', 7.days.ago)
        .order(date: :desc)

    # Filter runs based on user-specific distance requirements
    runs.select do |run|
      required_distance = get_long_run_distance_for_user(run.user)
      run.distance >= required_distance
    end
  end

  def long_runs_in_date_range(range)
    runs =
      Run
        .joins(:user)
        .where(users: { id: members.pluck(:id) })
        .in_date_range(range)

    # Filter runs based on user-specific distance requirements
    runs.select do |run|
      required_distance = get_long_run_distance_for_user(run.user)
      run.distance >= required_distance
    end
  end

  def members_in_common(user) =
    members.select do |member|
      member != user && member != owner && (member.teams & user.teams).any?
    end

  def any_members_in_common?(user) = members_in_common(user).any?

  def male_members = members.where(gender: 'male')

  def female_members = members.where(gender: 'female')

  def neutral_gender_members = members.where(gender: '')

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

  def get_long_run_distance_for_user(user)
    unless settings(:join_requirements).require_gender
      return settings(:runs).long_run_distance_neutral.to_i
    end

    if user.gender == 'male'
      settings(:runs).long_run_distance_male.to_i
    else
      settings(:runs).long_run_distance_female.to_i
    end
  end
end
