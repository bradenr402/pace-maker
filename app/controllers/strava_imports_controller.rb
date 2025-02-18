class StravaImportsController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user.strava_account_linked?
      StravaService.import_runs(current_user)
      flash[:notice] = 'Strava runs are being imported. This may take a few minutes.'
    else
      flash[:alert] = 'You need to connect your Strava account first.'
    end
    redirect_back fallback_location: edit_user_registration_path
  end
end
