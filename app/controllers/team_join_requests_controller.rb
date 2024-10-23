class TeamJoinRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_join_request, only: %i[update cancel approve reject]
  before_action :set_team, only: %i[cancel approve reject]
  before_action :authorize_owner!, only: %i[approve reject]

  def update
    eligibility_check = current_user.eligibility_for_team_membership(@team)

    unless eligibility_check[:allowed?]
      return(
        redirect_back fallback_location: teams_path,
                      alert: eligibility_check[:message]
      )
    end

    if @join_request.transaction do
         @join_request.pending! && @join_request.increment!(:request_number)
       end
      redirect_back fallback_location: teams_path,
                    success: 'Join request was successfully sent.'
    else
      redirect_back fallback_location: teams_path,
                    error: 'Unable to send join request.'
    end
  end

  def approve
    unless @join_request.approved!
      return(
        redirect_back fallback_location: @team,
                      error: 'Unable to approve join request.'
      )
    end

    @team.team_memberships.create(user: @join_request.user)
    redirect_back fallback_location: @team, success: 'Join request approved.'
  end

  def reject
    unless @join_request.rejected!
      return(
        redirect_back fallback_location: @team,
                      error: 'Unable to reject join request.'
      )
    end

    redirect_back fallback_location: @team, success: 'Join request rejected.'
  end

  def cancel
    unless @join_request.transaction {
             raise ActiveRecord::Rollback unless @join_request.canceled!

             @join_request.decrement!(:request_number)
           }
      return(
        redirect_back fallback_location: @team,
                      error: 'Unable to cancel join request.'
      )
    end

    redirect_back fallback_location: @team,
                  success: 'Join request was successfully canceled.'
  end

  private

  def set_join_request = @join_request = TeamJoinRequest.find(params[:id])
  def set_team = @team = Team.find(@join_request.team_id)

  def authorize_owner!
    unless current_user.owns?(@team)
      redirect_to @team, alert: 'You are not authorized to perform this action.'
    end
  end
end
