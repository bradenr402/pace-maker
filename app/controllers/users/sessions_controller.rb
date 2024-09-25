# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    flash.clear
    set_flash_message! :success, :signed_in
  end

  # DELETE /resource/sign_out
  def destroy
    super
    flash.clear
    set_flash_message! :success, :signed_out
  end

  # POST /users/sign_out_all
  def sign_out_all_devices
    new_password = Devise.friendly_token

    if current_user.update(encrypted_password: User.new(password: new_password).encrypted_password)
      bypass_sign_in(current_user)
      redirect_back fallback_location: root_path, success: 'Signed out of all devices.'
    else
      redirect_back fallback_location: root_path, alert: 'Failed to sign out of all devices.'
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
