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

    if @user.settings(:privacy).update(settings_params) &&
         @user.settings(:appearance).update(theme: settings_params[:theme]) &&
         @user.settings(:notifications).update(settings_params)
      redirect_to edit_user_registration_path,
                  success: 'Settings updated successfully.'
    else
      redirect_to edit_user_registration_path,
                  alert: 'Unable to update settings'
    end
  end

  private

  def user_settings_params =
    params
      .require(:user)
      .require(:settings)
      .permit(:email_visible, :phone_visible, :theme, :in_app)
end
