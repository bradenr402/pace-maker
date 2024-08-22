class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy join leave]
  before_action :authorize_owner!, only: %i[remove_member]

  def index
    @owned_teams = current_user.owned_teams
    @membered_teams = current_user.membered_teams

    @other_teams =
      if params[:query].present?
        sanitized_query = ActiveRecord::Base.connection.quote(params[:query])
        Team
          .joins(:owner)
          .where(
            'LOWER(teams.name) LIKE LOWER(:query) OR
            LOWER(users.username) LIKE LOWER(:query) OR
            LOWER(users.display_name) LIKE LOWER(:query) OR
            similarity(teams.name, :query) > 0.3 OR
            similarity(users.username, :query) > 0.3 OR
            similarity(users.display_name, :query) > 0.3',
            query: "%#{params[:query]}%"
          )
          .order(
            Arel.sql(
              "GREATEST(similarity(teams.name, #{sanitized_query}),
                          similarity(users.username, #{sanitized_query}),
                          similarity(users.display_name, #{sanitized_query}),
                          CASE
                            WHEN LOWER(teams.name) LIKE LOWER(#{sanitized_query})
                            THEN 1
                            ELSE 0
                          END) DESC"
            )
          )
      else
        current_user.other_teams
      end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @members =
      if params[:query].present?
        sanitized_query = ActiveRecord::Base.connection.quote(params[:query])
        @team
          .members
          .where(
            'LOWER(users.username) LIKE LOWER(:query) OR
            LOWER(users.display_name) LIKE LOWER(:query) OR
            similarity(users.username, :query) > 0.3 OR
            similarity(users.display_name, :query) > 0.3',
            query: "%#{params[:query]}%"
          )
          .order(
            Arel.sql(
              "GREATEST(similarity(users.username, #{sanitized_query}),
                          similarity(users.display_name, #{sanitized_query}),
                          CASE
                            WHEN LOWER(users.username) LIKE LOWER(#{sanitized_query})
                            THEN 1
                            ELSE 0
                          END) DESC"
            )
          )
      else
        @team.members
      end

    @date_range, @date_range_description =
      if params[:date_range].present?
        today = Date.today

        case params[:date_range]
        when 'All season'
          [@team.season_start_date..@team.season_end_date, 'this season']
        when 'This week'
          [today.beginning_of_week(@team.week_start)..today, 'this week']
        when 'Last week'
          one_week_ago = today - 1.week
          [
            one_week_ago.beginning_of_week(
              @team.week_start
            )..one_week_ago.end_of_week(@team.week_start),
            'last week'
          ]
        when 'This month'
          [today.beginning_of_month..today, 'this month']
        when 'Last month'
          one_month_ago = today - 1.month
          [
            one_month_ago.beginning_of_month..one_month_ago.end_of_month,
            'last month'
          ]
        when 'Custom range'
          start_date = params[:start_date].to_date
          end_date = params[:end_date].to_date
          [
            start_date..end_date,
            "between #{start_date.strftime('%m/%d/%Y')} and #{end_date.strftime('%m/%d/%Y')}"
          ]
        end
      else
        [@team.season_start_date..@team.season_end_date, 'this season']
      end

    if current_user.owns?(@team)
      @join_requests = @team.join_requests.pending.order(updated_at: :desc)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
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
    @team.photo.attach(params[:photo])
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
    requirement_check = current_user.meets_requirements?(@team)

    unless requirement_check[:allowed?]
      return(
        redirect_back fallback_location: teams_path,
                      alert: requirement_check[:message]
      )
    end

    join_request = @team.join_requests.new(user: current_user)

    if join_request.save
      redirect_back fallback_location: teams_path,
                    success: 'Join request was successfully sent.'
    else
      redirect_back fallback_location: teams_path,
                    alert: 'Unable to send join request.'
    end
  end

  def leave
    team_membership = @team.team_memberships.find_by(user_id: current_user)
    join_request =
      TeamJoinRequest.find_by(user_id: current_user, team_id: @team)

    if ActiveRecord::Base.transaction {
         join_request.pending! if join_request.present?
         team_membership&.destroy
       }
      redirect_back fallback_location: @team,
                    success: 'You have successfully left this team.'
    else
      redirect_back fallback_location: @team, alert: 'Unable to leave team.'
    end
  rescue StandardError
    redirect_back fallback_location: @team, alert: 'Unable to leave team.'
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

    if ActiveRecord::Base.transaction {
         join_request.rejected! && team_membership.destroy
       }
      redirect_back fallback_location: team,
                    success:
                      "#{member.default_name} was successfully removed from this team."
    else
      redirect_back fallback_location: team,
                    alert:
                      "Unable to remove #{member.default_name} from this team."
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
      :mileage_goal,
      :photo
    )

  def authorize_owner!
    team = Team.find(params[:team_id])
    unless current_user.owns?(team)
      redirect_to team, alert: 'You are not authorized to perform this action.'
    end
  end
end
