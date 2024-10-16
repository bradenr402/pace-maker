module UserSettings
  extend ActiveSupport::Concern

  def self.defaults
    {
      privacy: {
        email_visible: false,
        phone_visible: false
      },
      appearance: {
        theme: 'system'
      },
      notifications: {
        in_app: true
      }
    }
  end

  included do
    has_settings do |s|
      s.key :privacy, defaults: UserSettings.defaults[:privacy]
      s.key :appearance, defaults: UserSettings.defaults[:appearance]
      s.key :notifications, defaults: UserSettings.defaults[:notifications]
    end
  end

  def show_email? = settings(:privacy).email_visible
  def show_phone? = settings(:privacy).phone_visible
end
