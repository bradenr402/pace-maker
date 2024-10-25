module TeamSettings
  extend ActiveSupport::Concern

  def self.defaults
    {
      join_requirements: {
        require_gender: false,
        max_allowed_requests: 3
      },
      long_runs: {
        long_run_distance_male: 8,
        long_run_distance_female: 6,
        long_run_distance_neutral: 7
      },
      streaks: {
        include_saturday: false,
        include_sunday: false,
        streak_distance_male: 2,
        streak_distance_female: 2,
        streak_distance_neutral: 2
      },
      milestones: {
        streaks_increment: 10,
        mileage_increment: 50,
        long_runs_increment: 5
      },
      general: {
        week_start: :monday
      }
    }
  end

  included do
    has_settings do |s|
      s.key :join_requirements, defaults: TeamSettings.defaults[:join_requirements]
      s.key :long_runs, defaults: TeamSettings.defaults[:long_runs]
      s.key :streaks, defaults: TeamSettings.defaults[:streaks]
      s.key :milestones, defaults: TeamSettings.defaults[:milestones]
      s.key :general, defaults: TeamSettings.defaults[:general]
    end
  end

  def require_gender? = settings(:join_requirements).require_gender
  def max_allowed_requests = settings(:join_requirements).max_allowed_requests.to_i

  def week_start = settings(:general).week_start.to_sym

  def long_run_distance_male = settings(:long_runs).long_run_distance_male.to_i
  def long_run_distance_female = settings(:long_runs).long_run_distance_female.to_i
  def long_run_distance_neutral = settings(:long_runs).long_run_distance_neutral.to_i

  def include_saturday_in_streak? = settings(:streaks).include_saturday
  def include_sunday_in_streak? = settings(:streaks).include_sunday
  def exclude_saturday_from_streak? = !include_saturday_in_streak?
  def exclude_sunday_from_streak? = !include_sunday_in_streak?

  def include_date_in_streak?(date) =
    (date.saturday? && include_saturday_in_streak?) ||
      (date.sunday? && include_sunday_in_streak?)

  def exclude_date_from_streak?(date) =
    (date.saturday? && exclude_saturday_from_streak?) ||
      (date.sunday? && exclude_sunday_from_streak?)

  def streak_distance_male = settings(:streaks).streak_distance_male.to_i
  def streak_distance_female = settings(:streaks).streak_distance_female.to_i
  def streak_distance_neutral = settings(:streaks).streak_distance_neutral.to_i

  def streaks_increment = settings(:milestones).streaks_increment.to_i
  def long_runs_increment = settings(:milestones).long_runs_increment.to_i
  def mileage_increment = settings(:milestones).mileage_increment.to_i
end
