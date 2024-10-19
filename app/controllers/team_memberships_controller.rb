class TeamMembershipsController < ApplicationController
  before_action :set_team
  before_action :set_team_membership
  before_action :set_member
  before_action :authorize_member!

  def edit
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb @member.default_name, team_member_path(@team, @member)
    add_breadcrumb 'Edit Team Membership', edit_team_team_membership_path(@team, @member)
  end

  def update
    if @team_membership.update(team_membership_params)
      redirect_to team_member_path(@team, @team_membership.user),
                  success: 'Team membership was successfully updated.'
    else
      render :edit,
             status: :unprocessable_entity,
             error: 'Team membership could not be updated.'
    end
  end

  private

  def set_team = @team = Team.find(params[:team_id])

  def set_team_membership =
    @team_membership = @team.team_memberships.find_by(user_id: params[:user_id])

  def set_member = @member = @team_membership.user

  def team_membership_params =
    params.require(:team_membership).permit(:mileage_goal, :long_run_goal)

  def authorize_member!
    unless @team_membership.user == current_user
      redirect_to team_member_path(@team, @team_membership.user),
                  alert: 'You are not authorized to perform this action.'
    end
  end
end
