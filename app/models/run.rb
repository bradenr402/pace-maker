class Run < ApplicationRecord
  # Concerns
  include RunCalculations

  # Associations
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  # Validations
  validates :date, presence: true
  validates :distance,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }
  validate :date_not_in_future, unless: -> { strava_id.present? }
  validate :duration_requirements

  # Attributes
  attr_accessor :duration_input

  # Scopes
  scope :in_date_range, ->(range) { where(date: range).order(date: :desc) }
  scope :today, -> { where(date: Date.current.all_day).order(date: :desc) }
  scope :excluding_date, ->(date) { where.not(date:) }
  scope :recent_by_connected_users, lambda { |user|
    where(user_id: user.connected_user_ids)
      .where('date >= ?', 7.days.ago)
      .order(date: :desc)
  }

  # Methods
  def long_run_for_team?(team = nil)
    return false if team.nil? || !team.is_a?(Team)

    distance >= team.long_run_distance_for_user(user)
  end

  private

  def duration_requirements
    return if duration.blank?

    begin
      errors.add(:duration, 'Invalid interval format') unless duration.is_a?(ActiveSupport::Duration)
    rescue ArgumentError
      errors.add(:duration, 'Invalid duration format')
    end

    errors.add(:duration, 'Duration must be positive') if duration.negative?
  end

  def date_not_in_future
    errors.add(:date, 'cannot be in the future.') if date.future?
  end
end
