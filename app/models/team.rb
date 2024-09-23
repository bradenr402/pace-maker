class Team < ApplicationRecord
  include TeamCalculations
  include TeamSettings

  before_validation :convert_empty_string_season_dates_to_nil

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

  def season_in_progress? =
    season_dates? && Date.current.between?(season_start_date, season_end_date)

  def season_over? = season_dates? && season_end_date.past?

  def season_not_started_yet? = season_dates? && season_start_date.future?

  def gender_requirement_met?(user)
    return true unless require_gender?

    return true unless user.gender?

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

    runs.select do |run|
      required_distance = long_run_distance_for_user(run.user)
      run.distance >= required_distance
    end
  end

  def streak_runs
    runs =
      Run
      .joins(:user)
      .where(users: { id: members.pluck(:id) })
      .where('date >= ?', Date.current)
      .order(date: :desc)

    runs.select do |run|
      required_distance = streak_distance_for_user(run.user)
      run.distance >= required_distance
    end
  end

  def featured_runs = (recent_long_runs | streak_runs).sort_by(&:date).reverse

  def long_runs_in_date_range(range)
    runs =
      Run
      .joins(:user)
      .where(users: { id: members.pluck(:id) })
      .in_date_range(range)

    # Filter runs based on user-specific distance requirements
    runs.select do |run|
      required_distance = long_run_distance_for_user(run.user)
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

  def long_run_distance_for_user(user)
    return long_run_distance_neutral.to_i unless require_gender?

    user.male? ? long_run_distance_male.to_i : long_run_distance_female.to_i
  end

  def streak_distance_for_user(user)
    return streak_distance_neutral.to_i unless require_gender?

    user.male? ? streak_distance_male.to_i : streak_distance_female.to_i
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

  def convert_empty_string_season_dates_to_nil
    return if season_dates?

    self.season_start_date = nil
    self.season_end_date = nil
  end
end
