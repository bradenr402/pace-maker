class TeamJoinRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_join_request, only: %i[create destroy approve reject]
  before_action :set_team, only: %i[destroy approve reject]

  def create
    # join_request = @team.team_join_requests.new(user: current_user)
    if @join_request.save
      redirect_to teams_path, success: 'Request to join team has been sent.'
    else
      redirect_to teams_path, alert: 'Unable to send join request.'
    end
  end

  def destroy
    # join_request = @team.team_join_requests.find(params[:id])
    if @join_request.destroy
      redirect_to @team, success: 'Join request successfully canceled.'
    else
      redirect_to @team, error: 'Unable to cancel join request.'
    end
  end

  def approve
    # join_request = @team.team_join_requests.find(params[:id])
    if @join_request.approved!
      @team.team_memberships.create(user: @join_request.user)
      redirect_to @team, success: 'Join request approved.'
    else
      redirect_to @team, alert: 'Unable to approve join request.'
    end
  end

  def reject
    # join_request = @team.team_join_requests.find(params[:id])
    if @join_request.rejected!
      redirect_to @team, success: 'Join request rejected.'
    else
      redirect_to @team, alert: 'Unable to reject join request.'
    end
  end

  private

  def set_join_request = @join_request = TeamJoinRequest.find(params[:id])
  def set_team = @team = Team.find(@join_request.team_id)
end
