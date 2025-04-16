class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  before_action :set_event, only: %i[update destroy]
  before_action :authorize_owner!, only: %i[create update destroy]
  before_action :authorize_member!

  def create
    @event = @team.events.build(event_params)

    if @event.save
      flash[:success] = 'Event was successfully created.'
    else
      flash[:error] = 'Event could not be created.'
    end

    redirect_back fallback_location: team_calendar_path(@team, tab: 'eventsTab')
  end

  def update
    if @event.update(event_params)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to team_calendar_path(@team, tab: 'eventsTab'), success: 'Event was successfully updated.'
        end
      end
    else
      redirect_back fallback_location: team_calendar_path(@team, tab: 'eventsTab'), error: 'Event could not be updated.'
    end
  end

  def destroy
    @event = @team.events.find(params[:id])

    if @event.destroy
      flash[:success] = 'Event was successfully deleted.'
    else
      flash[:error] = 'Event could not be deleted.'
    end

    redirect_back fallback_location: team_calendar_path(@team, tab: 'eventsTab')
  end

  private

  def set_team = @team = Team.find(params[:team_id])

  def set_event = @event = @team.events.find(params[:id])

  def event_params =
    params.require(:event).permit(:title, :description, :start_date, :end_date, :location, :link, :photo, :remove_photo)

  def authorize_owner!
    team = Team.find(params[:team_id])
    return if current_user.owns?(team)

    redirect_to team, alert: 'You are not authorized to perform this action.'
  end

  def authorize_member!
    team = Team.find(params[:team_id])
    return if current_user.member_of?(team)

    redirect_to team, alert: 'You are not authorized to perform this action.'
  end
end
