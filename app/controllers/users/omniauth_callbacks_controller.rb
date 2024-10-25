# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  def google_oauth2
    # gets user from auth information
    @user = User.from_omniauth(auth)

    if @user.nil? # account already exists with email but is not linked to a Google account
      # links Google account to existing account if signed in, else asks user to sign in
      handle_existing_account
    elsif @user.persisted? # account linked to Google account
      # creates account with Google account and signs user in
      handle_successful_authentication
    else # error creating/linking account
      # displays error message and redirects to sign in page
      handle_failed_authentication
    end
  end

  private

  def handle_existing_account
    user_signed_in? ? handle_signed_in_user : handle_not_signed_in_user
  end

  def handle_signed_in_user
    if current_user.email == auth.info.email
      link_google_account
    else
      flash[
        :error
      ] = 'The email on your Google account does not match the one on your account.'
    end
  end

  def handle_not_signed_in_user
    store_location_for(:user, edit_user_registration_path)
    redirect_to new_user_session_path, alert: "An account already exists with the email <b>#{auth.info.email}</b>. Please sign in to link your Google account."
  end

  def link_google_account
    if current_user.update(provider: auth.provider, uid: auth.uid)
      flash[:success] = 'Your Google account was linked successfully.'
    else
      flash[:error] = 'There was an issue linking your Google account.'
    end
    redirect_to edit_user_registration_path
  end

  def handle_successful_authentication
    sign_out_all_scopes
    flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
    sign_in_and_redirect @user, event: :authentication
  end

  def handle_failed_authentication
    session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
    flash[:error] = t 'devise.omniauth_callbacks.failure',
      kind: 'Google',
      reason: "#{auth.info.email} is not authorized."
    redirect_to new_user_session_path
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
