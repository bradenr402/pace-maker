class TeamSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner!

  def update
    @team = Team.find(params[:team_id])

    settings_params =
      team_settings_params.transform_values do |value|
        %w[true false].include?(value) ? value == 'true' : value
      end

    settings_params[:require_gender] = false if @team.owner.gender.blank?

    if @team.settings(:join_requirements).update(
         settings_params.slice(:require_gender, :max_allowed_requests)
       ) &&
         @team.settings(:runs).update(
           settings_params.slice(
             :long_run_distance_male,
             :long_run_distance_female,
             :long_run_distance_neutral
           )
         ) &&
         @team.settings(:general).update(settings_params.slice(:week_start)) &&
         @team.settings(:streaks).update(
           settings_params.slice(
             :include_saturday,
             :include_sunday,
             :streak_distance_male,
             :streak_distance_female,
             :streak_distance_neutral
           )
         )
      redirect_to @team, success: 'Team settings updated successfully.'
    else
      redirect_to @team, error: 'Unable to update team settings.'
    end
  end

  private

  def team_settings_params =
    params
      .require(:team)
      .require(:settings)
      .permit(
        :require_gender,
        :max_allowed_requests,
        :long_run_distance_male,
        :long_run_distance_female,
        :long_run_distance_neutral,
        :week_start,
        :include_saturday,
        :include_sunday,
        :streak_distance_male,
        :streak_distance_female,
        :streak_distance_neutral
      )

  def authorize_owner!
    team = Team.find(params[:team_id])
    unless current_user.owns?(team)
      redirect_to team, alert: 'You are not authorized to perform this action.'
    end
  end
end
