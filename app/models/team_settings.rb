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
      s.key :general,
            defaults: {
              week_start: :monday
            }
    end
  end

  def require_gender? = settings(:join_requirements).require_gender
  def week_start = settings(:general).week_start.to_sym
end
