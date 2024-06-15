class Run < ApplicationRecord
  belongs_to :user

  validates :distance, :duration, :date, presence: true

  validates :distance, numericality: { greater_than_or_equal_to: 0 }

  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

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
