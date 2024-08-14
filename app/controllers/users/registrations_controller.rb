# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super
    flash.clear
    set_flash_message! :success, :signed_up
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource

  def update
    self.resource =
      resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(
      :unconfirmed_email
    )

    # Update user attributes including settings
    resource_updated =
      update_resource(resource, account_update_params.except(:current_password))
    yield resource if block_given?

    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      if sign_in_after_change_password?
        bypass_sign_in resource, scope: resource_name
      end

      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end

    flash.clear
    set_flash_message! :success, :updated
  end

  # DELETE /resource
  def destroy
    super
    flash.clear
    set_flash_message! :success, :destroyed
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [
        :display_name,
        :username,
        :email,
        :phone_number,
        :gender,
        :avatar,
        :remove_avatar,
        { settings: %i[email_visible phone_visible] }
      ]
    )
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def update_resource(resource, params)
    settings_params = params.delete(:settings) || {}
    resource.settings(:privacy).update(
      settings_params.transform_values do |value|
        value == 'true' if %w[true false].include?(value)
      end
    )

    # Require current password if user is trying to change password.
    resource.update_with_password(params) if params['password']&.present?

    # Allows user to update registration information without password.
    resource.update_without_password(params.except('current_password'))
  end
end
