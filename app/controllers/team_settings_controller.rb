class TeamSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner!

  def update
    @team = Team.find(params[:team_id])

    if params[:team][:copy_from_team_id].present?
      source_team =
        current_user.owned_teams.find(params[:team][:copy_from_team_id])

      copy_settings_from_team(source_team)
      return(
        redirect_to @team,
                    success:
                      "Team settings successfully copied from #{source_team.name}."
      )
    end

    settings_params =
      team_settings_params.transform_values do |value|
        %w[true false].include?(value) ? value == 'true' : value
      end

    settings_params[:require_gender] = false if @team.owner.gender.blank?

    if @team.settings(:join_requirements).update(
         settings_params.slice(:require_gender, :max_allowed_requests)
       ) &&
         @team.settings(:long_runs).update(
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
        :streak_distance_neutral,
        :copy_from_team_id
      )

  def copy_settings_from_team(source_team)
    join_requirements = source_team.settings(:join_requirements).value || {}
    @team.settings(:join_requirements).update(join_requirements)

    long_runs = source_team.settings(:long_runs).value || {}
    @team.settings(:long_runs).update(long_runs)

    streaks = source_team.settings(:streaks).value || {}
    @team.settings(:streaks).update(streaks)

    general = source_team.settings(:general).value || {}
    @team.settings(:general).update(general)

    # Save the team to persist the copied settings
    @team.save
  end

  def authorize_owner!
    team = Team.find(params[:team_id])
    unless current_user.owns?(team)
      redirect_to team, alert: 'You are not authorized to perform this action.'
    end
  end
end
