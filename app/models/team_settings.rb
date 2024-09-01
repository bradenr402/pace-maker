module TeamSettings
  extend ActiveSupport::Concern

  included do
    has_settings do |s|
      s.key :join_requirements,
            defaults: {
              require_gender: false,
              max_allowed_requests: 3
            }
      s.key :runs,
            defaults: {
              long_run_distance_male: 8,
              long_run_distance_female: 6,
              long_run_distance_neutral: 7
            }
      s.key :streaks,
            defaults: {
              include_saturday: false,
              include_sunday: false,
              streak_distance_male: 2,
              streak_distance_female: 2,
              streak_distance_neutral: 2
            }
      s.key :general, defaults: { week_start: :monday }
    end
  end

  def require_gender? = settings(:join_requirements).require_gender
  def week_start = settings(:general).week_start.to_sym

  def include_saturday_in_streak? = settings(:streaks).include_saturday
  def include_sunday_in_streak? = settings(:streaks).include_sunday
  def exclude_saturday_from_streak? = !include_saturday_in_streak?
  def exclude_sunday_from_streak? = !include_sunday_in_streak?

  def streak_distance_male = settings(:streaks).streak_distance_male
  def streak_distance_female = settings(:streaks).streak_distance_female
  def streak_distance_neutral = settings(:streaks).streak_distance_neutral
end
