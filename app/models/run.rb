class Run < ApplicationRecord
  include RunCalculations

  belongs_to :user

  validates :date, presence: true
  validates :distance,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }
  validate :date_not_in_future
  validate :duration_requirements

  attr_accessor :duration_input

  scope :in_date_range, ->(range) { where(date: range).order(date: :desc) }
  scope :today, -> { where(date: Date.today.all_day).order(date: :desc) }
  scope :excluding_date, ->(date) { where.not(date:) }

  def long_run_for?(team)
    return false unless team.present?

    required_distance = team.long_run_distance_for_user(user)

    distance >= required_distance
  end

  private

  def duration_requirements
    return if duration.blank?

    begin
      unless duration.is_a?(ActiveSupport::Duration)
        errors.add(:duration, 'Invalid interval format')
      end
    rescue ArgumentError
      errors.add(:duration, 'Invalid duration format')
    end

    errors.add(:duration, 'Duration must be positive') if duration.negative?
  end

  def date_not_in_future =
    (errors.add(:date, 'cannot be in the future.') if date.future?)
end
