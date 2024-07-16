class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy join leave]
  before_action :authorize_owner!, only: %i[remove_member]

  def index
    @owned_teams = current_user.owned_teams
    @membered_teams = current_user.membered_teams
    @other_teams = current_user.other_teams
  end

  def show
    @members = @team.members
    if current_user.owns?(@team)
      @join_requests = @team.join_requests.pending.order(updated_at: :desc)
    end
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.team_memberships.create(user: current_user) # Owner is also a member
      redirect_to @team, success: 'Team was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to @team, success: 'Team was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @team.destroy
      redirect_to teams_path, success: 'Team was successfully deleted.'
    else
      redirect_to @team, alert: 'Unable to delete team.'
    end
  end

  def join
    join_request = @team.join_requests.new(user: current_user)

    if join_request.save
      redirect_back fallback_location: @team,
                    success: 'Join request was successfully sent.'
    else
      redirect_back fallback_location: @team,
                    alert: 'Unable to send join request.'
    end
  end

  def leave
    team_membership = @team.team_memberships.find(user_id: current_user)

    if team_membership.destroy
      redirect_back fallback_location: @team,
                    success: 'You have successfully left this team.'
    else
      redirect_back fallback_location: @team, alert: 'Unable to leave team.'
    end
  end

  def remove_member
    team = Team.find(params[:team_id])
    member = team.members.find(params[:user_id])

    if member == current_user
      redirect_back fallback_location: team,
                    alert: 'You cannot remove yourself from the team.'
      return
    end

    join_request = TeamJoinRequest.find_by(user_id: member.id, team_id: team.id)
    team_membership = team.team_memberships.find_by(user: member)

    if join_request.rejected! && team_membership.destroy
      redirect_back fallback_location: team,
                    success:
                      "#{member.display_name.present? ? member.display_name : member.username} was successfully removed from this team."
    else
      redirect_back fallback_location: team,
                    alert: "Unable to remove #{member.display_name.present? ? member.display_name : member.username} from this team."
    end
  end

  private

  def set_team = @team = Team.find(params[:id])

  def team_params =
    params.require(:team).permit(
      :name,
      :description,
      :season_start_date,
      :season_end_date,
      :mileage_goal
    )

  def authorize_owner!
    team = Team.find(params[:team_id])
    unless current_user.owns?(team)
      redirect_to team, alert: 'You are not authorized to perform this action.'
    end
  end
end
