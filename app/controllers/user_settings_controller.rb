class UserSettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    @user.settings(:privacy) # Ensure settings are loaded
  end

  def update
    @user = current_user

    # convert string 'true' to true and string 'false' to false
    settings_params =
      user_settings_params.transform_values do |value|
        value == 'true'
      end

    if @user.settings(:privacy).update(settings_params)
      redirect_to current_user, success: 'Settings updated successfully'
    else
      render :edit, alert: 'Unable to update settings'
    end
  end

  private

  def user_settings_params =
    # params.require(:settings).permit(:email_visible, :phone_visible)
    params
      .require(:user)
      .require(:settings)
      .permit(:email_visible, :phone_visible)
end
