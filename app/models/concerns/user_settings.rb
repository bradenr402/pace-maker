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
      },
      navigation: {
        default_page: '/',
        show_pinned_pages_menu: true,
        show_pinned_pages_list: true
      }
    }
  end

  def reset_settings_to_defaults
    settings(:privacy).update(UserSettings.defaults[:privacy])
    settings(:appearance).update(UserSettings.defaults[:appearance])
    settings(:notifications).update(UserSettings.defaults[:notifications])
    settings(:strava).update(UserSettings.defaults[:strava])
    settings(:navigation).update(UserSettings.defaults[:navigation])
  end

  included do
    has_settings do |s|
      s.key :privacy, defaults: UserSettings.defaults[:privacy]
      s.key :appearance, defaults: UserSettings.defaults[:appearance]
      s.key :notifications, defaults: UserSettings.defaults[:notifications]
      s.key :strava, defaults: UserSettings.defaults[:strava]
      s.key :navigation, defaults: UserSettings.defaults[:navigation]
    end
  end

  def show_email? = settings(:privacy).email_visible
  def show_phone? = settings(:privacy).phone_visible

  def theme = settings(:appearance).theme

  def auto_import_strava? = settings(:strava).auto_import_strava

  def default_page = settings(:navigation).default_page

  def default_page_set? = default_page != UserSettings.defaults[:navigation][:default_page]

  def reset_default_page = settings(:navigation).update(default_page: nil)

  def show_pinned_pages_menu? = settings(:navigation).show_pinned_pages_menu
  def show_pinned_pages_list? = settings(:navigation).show_pinned_pages_list
end
