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
    end
  end

  def require_gender? = settings(:join_requirements).require_gender
end
