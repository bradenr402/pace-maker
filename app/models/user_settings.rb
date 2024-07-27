module UserSettings
  extend ActiveSupport::Concern

  included do
    has_settings do |s|
      s.key :privacy, defaults: { email_visible: false, phone_visible: false }
    end
  end
end
