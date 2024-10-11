# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  def google_oauth2
    @user = User.from_omniauth(auth)

    if @user.nil? # account already exists with email
      if user_signed_in?
        if current_user.update(provider: auth.provider, uid: auth.uid)
          flash[:success] = 'Your Google account was linked successfully.'
        else
          flash[:error] = 'There was an issue linking your Google account.'
        end
        redirect_to edit_user_registration_path
      else # account already exists with email, but user is not signed in
        flash[:alert] = "An account already exists with the email <b>#{auth.info.email}</b>. Please sign in to link your Google account."
        store_location_for(:user, edit_user_registration_path)
        redirect_to new_user_session_path
      end
    elsif @user.persisted? # not new_record? (i.e., account created and saved without errors)
      sign_out_all_scopes
      flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      flash[:error] =
        t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
      redirect_to new_user_session_path
    end
  end

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

  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
