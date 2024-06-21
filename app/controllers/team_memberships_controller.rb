class TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team

  # def create
  #   if @team.team_memberships.where(user: current_user).none?
  #     @team.team_memberships.create(user: current_user)
  #     redirect_to @team, success: "You successfully joined the team #{@team.name}."
  #   else
  #     redirect_to @team, alert: 'You are already a member of this team.'
  #   end
  # end

  # private

  # def set_team = @team.find(params[:id])
end
