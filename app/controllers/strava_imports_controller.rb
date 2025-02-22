class StravaImportsController < ApplicationController
  before_action :authenticate_user!

  def create
    unless current_user.strava_account_linked?
      flash[:alert] = 'You need to connect your Strava account first.'
      return redirect_back fallback_location: edit_user_registration_path
    end

    begin
      StravaService.import_runs(current_user)
      flash[:notice] = 'Strava runs are being imported. This may take a few minutes.'
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back fallback_location: edit_user_registration_path
  end

  def destroy
    if current_user.strava_runs.destroy_all
      flash[:notice] = 'Your imported Strava runs have been deleted.'
    else
      flash[:error] = 'There was an error deleting your Strava runs. Please try again.'
    end
    redirect_back fallback_location: edit_user_registration_path
  end
end
