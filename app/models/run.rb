class Run < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :distance,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }
  validates :duration, presence: true
  validate :date_not_in_future
  validate :duration_requirements

  attr_accessor :duration_input

  def hours
    (duration / 3600).to_i
  end

  def minutes
    ((duration % 3600) / 60).to_i
  end

  def seconds
    (duration % 60).to_i
  end

  def distance_km
    (distance * 1.609344).round(3)
  end

  def pace_per_mile
    (duration / distance).round
  end

  def pace_per_km
    (duration / distance_km).round
  end

  private

  def duration_requirements
    return unless duration

    unless duration.is_a?(ActiveSupport::Duration)
      errors.add(:duration, 'Invalid interval format')
    end
    errors.add(:duration, 'Duration must be positive') if duration.negative?
  end

  def date_not_in_future
    errors.add(:date, 'cannot be in the future.') if date.future?
  end
end
