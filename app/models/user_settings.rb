module UserSettings
  extend ActiveSupport::Concern

  included do
    has_settings do |s|
      s.key :privacy, defaults: { email_visible: false, phone_visible: false }
      s.key :appearance, defaults: { theme: 'system' }
      s.key :notifications, defaults: { in_app: true }
    end
  end

  def show_email? = settings(:privacy).email_visible
  def show_phone? = settings(:privacy).phone_visible
end
