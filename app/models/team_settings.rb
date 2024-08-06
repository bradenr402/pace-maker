module TeamSettings
  extend ActiveSupport::Concern

  included do
    has_settings do |s|
      s.key :join_requirements, defaults: { require_gender: false, max_allowed_requests: 3 }
    end
  end
end
