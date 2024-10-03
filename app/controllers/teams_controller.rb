class TeamsController < ApplicationController
  include DateHelper

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
    @members = get_members

    @rankings_date_range, @rankings_date_range_description = get_rankings_date_range_and_description
    @trends_date_range, @trends_date_range_description = get_trends_date_range_and_description

    @miles_data = get_team_miles_data
    @long_runs_data = get_team_long_runs_data

    @join_requests = @team.join_requests.pending.order(updated_at: :desc) if current_user.owns?(@team)

    respond_to do |format|
      format.html
      format.turbo_stream
      format.xlsx do
        time = Time.now

        # Manually format hour to 12-hour format
        hour_12 = time.hour % 12
        hour_12 = hour_12.zero? ? 12 : hour_12 # Handle midnight/noon

        @pretty_timestamp =
          "#{time.strftime('%B %d, %Y at ')}#{hour_12}:#{time.strftime('%M %P')}"
        @male_members = @team.male_members if @team.require_gender?
        @female_members = @team.female_members if @team.require_gender?

        sanitized_team_name = @team.name.gsub(/[^0-9A-Za-z.\-_]/, '_')
        timestamp = time.strftime('%Y_%m_%d_at_%H-%M-%S')
        filename = "#{sanitized_team_name}_team_rankings_#{timestamp}.xlsx"
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=\"#{filename}\""
      end
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
      render :new,
             status: :unprocessable_entity,
             error: 'Team could not be created.'
    end
  end

  def edit; end

  def update
    @team.photo.attach(params[:photo])
    if @team.update(team_params)
      redirect_to @team, success: 'Team was successfully updated.'
    else
      render :edit,
             status: :unprocessable_entity,
             error: 'Team could not be updated.'
    end
  end

  def destroy
    if @team.destroy
      redirect_to teams_path, success: 'Team was successfully deleted.'
    else
      redirect_to @team, error: 'Unable to delete team.'
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
                    error: 'Unable to send join request.'
    end
  end

  def leave
    team_membership = @team.team_memberships.find_by(user_id: current_user)
    join_request =
      TeamJoinRequest.find_by(user_id: current_user, team_id: @team)

    if ActiveRecord::Base.transaction do
         join_request.pending! if join_request.present?
         team_membership&.destroy
       end
      redirect_back fallback_location: @team,
                    success: 'You have successfully left this team.'
    else
      redirect_back fallback_location: @team, error: 'Unable to leave team.'
    end
  rescue StandardError
    redirect_back fallback_location: @team, error: 'Unable to leave team.'
  end

  def remove_member
    team = Team.find(params[:team_id])
    member = team.members.find(params[:user_id])

    if member == current_user
      redirect_back fallback_location: team,
                    error: 'You cannot remove yourself from the team.'
      return
    end

    join_request = TeamJoinRequest.find_by(user_id: member.id, team_id: team.id)
    team_membership = team.team_memberships.find_by(user: member)

    if ActiveRecord::Base.transaction do
         join_request.rejected! && team_membership.destroy
       end
      redirect_back fallback_location: team,
                    success:
                      "#{member.default_name} was successfully removed from this team."
    else
      redirect_back fallback_location: team,
                    error:
                      "Unable to remove #{member.default_name} from this team."
    end
  end

  def member
    @team = Team.find(params[:team_id])
    @member = @team.members.find(params[:user_id])
    @team_membership = @team.team_memberships.find_by(user: @member)

    @trends_date_range, @trends_date_range_description = get_trends_date_range_and_description

    @miles_data = get_member_miles_data
    @long_runs_data = get_member_long_runs_data
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
      :long_run_goal,
      :photo
    )

  def authorize_owner!
    team = Team.find(params[:team_id])
    return if current_user.owns?(team)

    redirect_to team, alert: 'You are not authorized to perform this action.'
  end

  def get_members
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
  end

  def get_rankings_date_range_and_description
    if params[:rankings_date_range].present?
      today = Date.today

      case params[:rankings_date_range]
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
        start_date = params[:rankings_start_date].to_date
        end_date = params[:rankings_end_date].to_date
        [
          start_date..end_date,
          "between #{format_date(start_date, separator: '.')} and #{pretty_date(end_date, separator: '.')}"
        ]
      end
    else
      [@team.season_start_date..@team.season_end_date, 'this season']
    end
  end

  def get_trends_date_range_and_description
    today = Date.today

    if params[:trends_date_range].present?
      case params[:trends_date_range]
      when 'All season'
        [@team.season_start_date..@team.season_end_date, 'this season']
      when 'This week'
        [week_range(
          current_date: today,
          week_start: @team.week_start
        ), 'this week']
      when 'Last week'
        [week_range(
          current_date: today - 1.week,
          week_start: @team.week_start
        ), 'last week']
      when 'This month'
        [month_range(current_date: today), 'this month']
      when 'Last month'
        [month_range(current_date: today - 1.month), 'last month']

      when 'Custom range'
        start_date = params[:trends_start_date].to_date
        end_date = params[:trends_end_date].to_date

        [start_date..end_date,
         "between #{format_date(start_date, separator: '.')} and #{format_date(end_date, separator: '.')}"]
      end
    else
      [week_range(
        current_date: today,
        week_start: @team.week_start
      ), 'this week']
    end
  end

  def get_team_miles_data
    group_by = params[:group_by] || 'day'

    if group_by == 'week'
      @trends_date_range.group_by { |date| date.beginning_of_week(@team.week_start) }.map do |week_start, dates|
        [
          pretty_date(week_start, month_format: :short, date_style: :absolute),
          dates.sum { |date| @team.miles_in_date_range(date) }
        ]
      end
    else # group_by == 'day'
      @trends_date_range.map do |date|
        [
          pretty_date(date, month_format: :short, date_style: :absolute),
          @team.miles_in_date_range(date)
        ]
      end
    end
  end

  def get_team_long_runs_data
    group_by = params[:group_by] || 'day'

    if group_by == 'week'
      @trends_date_range.group_by { |date| date.beginning_of_week(@team.week_start) }.map do |week_start, dates|
        [
          pretty_date(week_start, month_format: :short, date_style: :absolute),
          dates.sum { |date| @team.long_runs_in_date_range(date).count }
        ]
      end
    else # group_by == 'day'
      @trends_date_range.map do |date|
        [
          pretty_date(date, month_format: :short, date_style: :absolute),
          @team.long_runs_in_date_range(date).count
        ]
      end
    end
  end

  def get_member_miles_data
    group_by = params[:group_by] || 'day'

    if group_by == 'week'
      @trends_date_range.group_by { |date| date.beginning_of_week(@team.week_start) }.map do |week_start, dates|
        [
          pretty_date(week_start, month_format: :short, date_style: :absolute),
          dates.sum { |date| @member.miles_in_date_range(date) }
        ]
      end
    else # group_by == 'day'
      @trends_date_range.map do |date|
        [
          pretty_date(date, month_format: :short, date_style: :absolute),
          @member.miles_in_date_range(date)
        ]
      end
    end
  end

  def get_member_long_runs_data
    group_by = params[:group_by] || 'day'

    if group_by == 'week'
      @trends_date_range.group_by { |date| date.beginning_of_week(@team.week_start) }.map do |week_start, dates|
        [
          pretty_date(week_start, month_format: :short, date_style: :absolute),
          dates.sum { |date| @member.long_runs_in_date_range(@team, date).count }
        ]
      end
    else # group_by == 'day'
      @trends_date_range.map do |date|
        [
          pretty_date(date, month_format: :short, date_style: :absolute),
          @member.long_runs_in_date_range(@team, date).count
        ]
      end
    end
  end
end
