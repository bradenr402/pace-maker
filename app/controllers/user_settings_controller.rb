class UserSettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user

    # Ensure settings are loaded
    @user.settings(:privacy)
    @user.settings(:appearance)
  end

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
         @user.settings(:appearance).update(theme: settings_params[:theme])
      redirect_to current_user, success: 'Settings updated successfully'
    else
      render :edit, alert: 'Unable to update settings'
    end
  end

  private

  def user_settings_params =
    params
      .require(:user)
      .require(:settings)
      .permit(:email_visible, :phone_visible, :theme)
end
