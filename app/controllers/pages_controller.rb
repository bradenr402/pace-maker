class PagesController < ApplicationController
  layout 'landing', only: [:landing]

  def privacy_policy
    add_breadcrumb 'Settings', edit_user_registration_path
    add_breadcrumb 'Help', edit_user_registration_path(tab: 'helpTab')
    add_breadcrumb 'Privacy Policy', privacy_policy_path
  end
  def strava_policy
    add_breadcrumb 'Settings', edit_user_registration_path
    add_breadcrumb 'Help', edit_user_registration_path(tab: 'helpTab')
    add_breadcrumb 'Strava Data Usage Policy', strava_policy_path
  end
  def google_policy
    add_breadcrumb 'Settings', edit_user_registration_path
    add_breadcrumb 'Help', edit_user_registration_path(tab: 'helpTab')
    add_breadcrumb 'Google Data Usage Policy', google_policy_path
  end
  def landing; end
end
