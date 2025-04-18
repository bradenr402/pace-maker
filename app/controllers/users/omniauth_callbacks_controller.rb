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
    @user = User.from_google_omniauth(auth)

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

  def strava
    unless user_signed_in?
      Rails.logger.warn 'Strava OAuth attempted without a signed-in user.'
      return redirect_to new_user_session_path,
                         alert: 'Please sign in to link your Strava account.'
    end

    Rails.logger.info "Strava OAuth uid received for user #{current_user.id}: #{auth.uid}"

    required_scopes = %w[read activity:read profile:read_all]
    granted_scopes = params[:scope]&.split(',') || []

    unless (required_scopes - granted_scopes).empty?
      Rails.logger.warn(
        "Strava OAuth failed: Missing required scopes for user #{current_user.id}. " \
        "Required scopes: #{required_scopes}. " \
        "Granted scopes: #{granted_scopes}."
      )
      return redirect_to(
        edit_user_registration_path,
        alert: 'You did not accept all required Strava permissions. Please check <i>&#8220;View data about your activities&#8221;</i> to connect your Strava account.'
      )
    end

    if current_user.update(
      strava_uid: auth.uid,
      strava_access_token: auth.credentials.token,
      strava_refresh_token: auth.credentials.refresh_token,
      strava_token_expires_at: Time.at(auth.credentials.expires_at),
      strava_accepted_scope: params[:scope]
    )
      Rails.logger.info "Strava OAuth success: Account linked for user #{current_user.id}."
      flash[:success] = 'Your Strava account was successfully connected.'
    else
      Rails.logger.error "Strava OAuth failed: Unable to link account for user #{current_user.id}."
      flash[:error] = 'There was an issue connecting your Strava account.'
    end

    redirect_to edit_user_registration_path
  end

  def failure
    if params[:error] == 'access_denied'
      Rails.logger.info 'Strava OAuth failed: Access denied.'
      return redirect_to edit_user_registration_path,
                         alert: 'You denied access to your Strava account. If this was a mistake, please try again.'
    end

    redirect_to edit_user_registration_path,
                error: 'There was an issue connecting your Strava account.'
  end

  private

  def handle_existing_account
    user_signed_in? ? handle_signed_in_user : handle_not_signed_in_user
  end

  def handle_signed_in_user
    if current_user.email != auth.info.email
      return redirect_to(
        edit_user_registration_path,
        error: 'The email on the Google account you selected does not match the one on your PaceMaker account.'
      )
    end

    link_google_account
    redirect_to edit_user_registration_path, error: 'There was an issue linking your account.'
  end

  def handle_not_signed_in_user
    store_location_for(:user, edit_user_registration_path)
    redirect_to(
      new_user_session_path,
      alert: "An account already exists with the email <b>#{auth.info.email}</b>. Please sign in to link your Google account."
    )
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
    session["devise.#{auth.provider}_data"] = request.env['omniauth.auth'].except('extra')
    redirect_to(
      new_user_session_path,
      error: t('devise.omniauth_callbacks.failure',
               kind: 'Google',
               reason: "#{auth.info.email} is not authorized.")
    )
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
