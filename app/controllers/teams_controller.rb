class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy join leave]

  def index
    @teams = Team.all
    # @teams = current_user.teams + current_user.owned_teams
  end

  def show
    @members = @team.members
    @join_requests = @team.team_join_requests.pending if @team.owner ==
      current_user
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
    join_request = @team.team_join_requests.new(user: current_user)

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

  private

  def set_team = @team = Team.find(params[:id])

  def team_params = params.require(:team).permit(:name, :description)
end
