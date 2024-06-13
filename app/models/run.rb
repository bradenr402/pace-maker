class Run < ApplicationRecord
  belongs_to :user

  validates :distance, :duration, :date, presence: true

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

  def average_speed_mph
    ((distance / (duration.to_f / 3600))).round(2)
  end

  def average_speed_kph
    ((distance_km / (duration.to_f / 3600))).round(2)
  end

  def pace_per_mile
    (duration / distance).round
  end

  def pace_per_km
    (duration / distance_km).round
  end
end
