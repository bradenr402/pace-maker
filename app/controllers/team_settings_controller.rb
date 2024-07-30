class TeamSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner!

  def update
    @team = Team.find(params[:team_id])

    Rails.logger.info(
      "____________________________________________________Params: #{params.inspect}"
    )

    settings_params =
      team_settings_params.transform_values do |value|
        value == 'true' if %w[true false].include?(value)
      end

    if @team.settings(:join_requirements).update(settings_params)
      redirect_to @team, success: 'Team settings updated successfully'
    else
      redirect_to @team, alert: 'Unable to update team settings'
    end
  end

  private

  def team_settings_params =
    params.require(:team).require(:settings).permit(:require_gender)

  def authorize_owner!
    team = Team.find(params[:team_id])
    unless current_user.owns?(team)
      redirect_to team, alert: 'You are not authorized to perform this action.'
    end
  end
end
