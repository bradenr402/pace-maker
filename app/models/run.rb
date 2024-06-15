class Run < ApplicationRecord
  belongs_to :user

  validates :distance, :duration, :date, presence: true

  validates :distance, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_duration

  validate :date_not_in_future

  attr_accessor :duration_input

  def validate_duration
    return unless duration

    errors.add(:duration, 'Invalid interval format') unless duration.is_a?(ActiveSupport::Duration)
    errors.add(:duration, 'Duration must be positive') if duration.negative?
  end

  def date_not_in_future
    errors.add(:date, 'cannot be in the future.') if date > Date.today
  end

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
end
