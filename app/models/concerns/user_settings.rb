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
      },
      strava: {
        auto_import_strava: false
      }
    }
  end

  def reset_settings_to_defaults
    settings(:privacy).update(UserSettings.defaults[:privacy])
    settings(:appearance).update(UserSettings.defaults[:appearance])
    settings(:notifications).update(UserSettings.defaults[:notifications])
    settings(:strava).update(UserSettings.defaults[:strava])
  end

  included do
    has_settings do |s|
      s.key :privacy, defaults: UserSettings.defaults[:privacy]
      s.key :appearance, defaults: UserSettings.defaults[:appearance]
      s.key :notifications, defaults: UserSettings.defaults[:notifications]
      s.key :strava, defaults: UserSettings.defaults[:strava]
    end
  end

  def show_email? = settings(:privacy).email_visible
  def show_phone? = settings(:privacy).phone_visible

  def theme = settings(:appearance).theme

  def auto_import_strava? = settings(:strava).auto_import_strava
end
