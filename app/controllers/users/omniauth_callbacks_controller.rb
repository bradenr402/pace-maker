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

    code = params[:code]
    unless code.present?
      Rails.logger.error 'Strava OAuth failed: Missing authorization code.'
      return redirect_to edit_user_registration_path, alert: 'Authentication data missing.'
    end

    Rails.logger.info "Strava OAuth success: Authorization code received for user #{current_user.id}"

    if exchange_strava_code_for_tokens(code)
      Rails.logger.info "Strava OAuth success: Account linked for user #{current_user.id}."
      flash[:success] = 'Your Strava account was successfully linked.'
    else
      Rails.logger.error "Strava OAuth failure: Unable to exchange code for tokens for user #{current_user.id}."
      flash[:error] = 'There was an issue linking your Strava account.'
    end

    redirect_to edit_user_registration_path
  end

  def failure
    redirect_back fallback_location: edit_user_registration_path,
                  error: 'There was an issue linking your account.'
  end

  private

  def handle_existing_account
    user_signed_in? ? handle_signed_in_user : handle_not_signed_in_user
  end

  def handle_signed_in_user
    if auth.provider == 'google_oauth2' && current_user.email != auth.info.email
      flash[:error] =
        "The email on your #{pretty_provider_name(auth.provider)} account does not match the one on your account."
      redirect_to edit_user_registration_path
      return
    end

    if auth.provider == 'google_oauth2'
      link_google_account
    elsif auth.provider == 'strava'
      link_strava_account
    else
      redirect_to edit_user_registration_path, error: 'There was an issue linking your account.'
    end
  end

  def handle_not_signed_in_user
    store_location_for(:user, edit_user_registration_path)
    redirect_to new_user_session_path,
                alert: "An account already exists with the email <b>#{auth.info.email}</b>. Please sign in to link your #{pretty_provider_name(auth.provider)} account."
  end

  def link_google_account
    if current_user.update(provider: auth.provider, uid: auth.uid)
      flash[:success] = 'Your Google account was linked successfully.'
    else
      flash[:error] = 'There was an issue linking your Google account.'
    end
    redirect_to edit_user_registration_path
  end

  def exchange_strava_code_for_tokens(code)
    Rails.logger.info "Strava OAuth: Exchanging authorization code for tokens for user #{current_user.id}."

    params = {
      client_id: Rails.application.credentials[:strava_client_id],
      client_secret: Rails.application.credentials[:strava_client_secret],
      code: code,
      grant_type: 'authorization_code'
    }

    # Log the request parameters to inspect them
    Rails.logger.info "Sending params: #{params}"

    response = RestClient.post('https://www.strava.com/oauth/token', params)

    unless response.code == 200
      Rails.logger.error "Strava OAuth token exchange failed for user #{current_user.id}: #{response.body}"
      Rails.logger.error "Full response: #{response.inspect}" # Log the entire response object
      return false
    end

    body = JSON.parse(response.body)
    Rails.logger.info "Strava OAuth token exchange success for user #{current_user.id}: Access token received."

    current_user.update(
      strava_uid: body.dig('athlete', 'id'),
      strava_access_token: body['access_token'],
      strava_refresh_token: body['refresh_token'],
      strava_token_expires_at: Time.at(body['expires_at'])
    )
  rescue RestClient::BadRequest => e
    Rails.logger.error "Strava OAuth token exchange error for user #{current_user.id}: #{e.response}"
    false
  rescue StandardError => e
    Rails.logger.error "An unexpected error occurred during Strava OAuth token exchange for user #{current_user.id}: #{e.message}"
    false
  end

  def handle_successful_authentication
    sign_out_all_scopes
    flash[:success] = t 'devise.omniauth_callbacks.success', kind: pretty_provider_name(auth.provider)
    sign_in_and_redirect @user, event: :authentication
  end

  def handle_failed_authentication
    session["devise.#{auth.provider}_data"] = request.env['omniauth.auth'].except('extra')
    flash[:error] = t 'devise.omniauth_callbacks.failure',
                      kind: pretty_provider_name(auth.provider),
                      reason: "#{auth.info.email} is not authorized."
    redirect_to new_user_session_path
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end

  def pretty_provider_name(provider)
    if provider == 'google_oauth2'
      'Google'
    elsif provider == 'strava'
      'Strava'
    else
      provider.capitalize
    end
  end
end
