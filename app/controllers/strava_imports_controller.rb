class StravaImportsController < ApplicationController
  before_action :authenticate_user!

  def create
    unless current_user.strava_account_linked?
      flash[:alert] = 'You need to connect your Strava account first.'
      return redirect_back fallback_location: edit_user_registration_path
    end

    if current_user.strava_token_expired?
      current_user.refresh_strava_token!
      if current_user.errors.any?
        flash[:error] = 'Unable to connect to Strava. Please try again.'
        return redirect_back fallback_location: edit_user_registration_path
      end
    end

    StravaService.import_runs(current_user)
    flash[:notice] = 'Strava runs are being imported. This may take a few minutes.'
    redirect_back fallback_location: edit_user_registration_path
  end

  def destroy
    current_user.strava_runs.destroy_all
    flash[:notice] = 'Your imported Strava runs have been deleted.'
    redirect_back fallback_location: edit_user_registration_path
  end
end
