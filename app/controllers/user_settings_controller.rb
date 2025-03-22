class UserSettingsController < ApplicationController
  before_action :authenticate_user!

  def update
    @user = current_user

    settings_params =
      user_settings_params.transform_values do |value|
        case value
        when 'true' then true
        when 'false' then false
        else value
        end
      end

    settings_params[:theme] = user_settings_params[:theme] if %w[
      light
      dark
      system
    ].include?(user_settings_params[:theme])

    if @user.settings(:privacy).update(settings_params.slice(:email_visible, :phone_visible)) &&
       @user.settings(:appearance).update(settings_params.slice(:theme)) &&
       @user.settings(:notifications).update(settings_params.slice(:in_app)) &&
       @user.settings(:strava).update(settings_params.slice(:auto_import_strava)) &&
       @user.settings(:navigation).update(settings_params.slice(
                                            :default_page,
                                            :show_pinned_pages_menu,
                                            :show_pinned_pages_list
                                          ))
      flash[:success] = 'Settings updated successfully.'
    else
      flash[:error] = 'Unable to update settings.'
    end

    redirect_back fallback_location: edit_user_registration_path(tab: 'settingsTab')
  end

  def reset
    current_user.reset_settings_to_defaults

    redirect_to edit_user_registration_path(tab: 'settingsTab'),
                success: 'Your settings have been reset.'
  end

  private

  def user_settings_params =
    params
      .require(:user)
      .require(:settings)
      .permit(
        :email_visible,
        :phone_visible,
        :theme,
        :in_app,
        :auto_import_strava,
        :default_page,
        :show_pinned_pages_menu,
        :show_pinned_pages_list
      )
end
