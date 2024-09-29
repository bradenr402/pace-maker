class UserSettingsController < ApplicationController
  before_action :authenticate_user!

  def update
    @user = current_user

    settings_params =
      user_settings_params.transform_values do |value|
        value == 'true' if %w[true false].include?(value)
      end

    settings_params[:theme] = user_settings_params[:theme] if %w[
      light
      dark
      system
    ].include?(user_settings_params[:theme])

    if @user.settings(:privacy).update(
      settings_params.slice(:email_visible, :phone_visible)
    ) && @user.settings(:appearance).update(settings_params.slice(:theme)) &&
       @user.settings(:notifications).update(settings_params.slice(:in_app))
      redirect_to edit_user_registration_path(tab: 'settingsTab'),
                  success: 'Settings updated successfully.'
    else
      redirect_to edit_user_registration_path(tab: 'settingsTab'),
                  error: 'Unable to update settings.'
    end
  end

  private

  def user_settings_params =
    params
      .require(:user)
      .require(:settings)
      .permit(:email_visible, :phone_visible, :theme, :in_app)
end
