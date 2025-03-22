class PagesController < ApplicationController
  include ActionView::Helpers::UrlHelper

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

  def default
    return redirect_to landing_path unless user_signed_in?

    return redirect_to home_path unless current_user.default_page_set?

    unless valid_route?(current_user.default_page)
      current_user.reset_default_page
      return(
        redirect_to home_path,
                    alert: 'Invalid default start page. Redirecting to home. ' \
                           'Your default start page has been reset to home. ' \
                           "Go to #{link_to 'Settings',
                                            settings_path(tab: 'settingsTab'),
                                            class: 'italic font-bold',
                                            data: { turbo: false }} to set a new default page."
      )
    end

    redirect_to current_user.default_page || home_path
  end
end
