class TeamsController < ApplicationController
  include DateHelper

  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy join leave edit_members update_members]
  before_action :authorize_owner!, only: %i[remove_member edit_members update_members]
  before_action :authorize_member!, only: %i[calendar member_calendar]

  def index
    add_breadcrumb 'Teams', teams_path

    @owned_teams =
      current_user.owned_teams.with_attached_photo.includes(
        :owner,
        :setting_objects,
        :members
      )
    @membered_teams =
      current_user.membered_teams.with_attached_photo.includes(
        :owner,
        :setting_objects,
        :members
      )
  end

  def show
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)

    @query = params[:query]

    @members =
      Rails
      .cache
      .fetch("#{@team.cache_key}/members/#{@query}", expires_in: 1.hour) do
        get_members
      end

    @current_user_owns_team = current_user.owns?(@team)
    @current_user_member_of_team = current_user.member_of?(@team)

    @tab = params[:tab]

    case @tab
    when 'rankings'
      @rankings_date_range, @rankings_date_range_description = get_rankings_data
      @rankings_date_range_param = params[:rankings_date_range] || @team.season_dates? ? 'all_season' : 'this_week'

      @all_members = @team.filtered_members.map do |member|
        {
          member: member,
          total_miles: member.miles_in_date_range(@rankings_date_range),
          total_long_runs: member.total_long_runs_in_date_range(@team, @rankings_date_range),
          current_streak: member.current_streak(@team)[:streak],
          record_streak: member.record_streak(@team)[:streak]
        }
      end

      @all_members.sort_by! { |data| [-data[:total_miles], data[:member].default_name] }
    when 'trends'
      @trends_date_range, @trends_date_range_description = get_trends_data
      @trends_date_range_param = params[:trends_date_range] || @team.season_dates? ? 'all_season' : 'this_week'

      @miles_data = get_team_miles_data
      @long_runs_data = get_team_long_runs_data
    end

    respond_to do |format|
      format.html
      format.turbo_stream
      format.xlsx do
        time = Time.now

        # Manually format hour to 12-hour format
        hour_12 = time.hour % 12
        hour_12 = hour_12.zero? ? 12 : hour_12 # Handle midnight/noon

        @rankings_date_range, @rankings_date_range_description = get_rankings_data

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

  def tab
    @team = Team.find(params[:team_id])
    @tab = params[:tab]

    @current_user_owns_team = current_user.owns?(@team)
    @current_user_member_of_team = current_user.member_of?(@team)

    allowed_tabs = %w[team_info members]
    allowed_tabs << 'join_requests' if @current_user_owns_team
    allowed_tabs.concat(%w[rankings trends featured recent_activity]) if @current_user_member_of_team

    raise ActionController::RoutingError, 'Not Found' unless allowed_tabs.include?(@tab)

    case @tab
    when 'members'
      @members = Rails.cache.fetch("#{@team.cache_key}/members", expires_in: 1.hour) do
        @team.members.with_attached_avatar
      end
    when 'join_requests'
      if current_user.owns?(@team)
        @join_requests = @team.join_requests.includes(user: :avatar_attachment).pending.order(updated_at: :desc)
      end
    when 'rankings'
      @rankings_date_range, @rankings_date_range_description = get_rankings_data
      @rankings_date_range_param = params[:rankings_date_range] || @team.season_dates? ? 'all_season' : 'this_week'

      @all_members = @team.filtered_members.map do |member|
        {
          member: member,
          total_miles: member.miles_in_date_range(@rankings_date_range),
          total_long_runs: member.total_long_runs_in_date_range(@team, @rankings_date_range),
          current_streak: member.current_streak(@team)[:streak],
          record_streak: member.record_streak(@team)[:streak]
        }
      end

      @all_members.sort_by! { |data| [-data[:total_miles], data[:member].default_name] }
    when 'trends'
      @trends_date_range, @trends_date_range_description = get_trends_data
      @trends_date_range_param = params[:trends_date_range] || @team.season_dates? ? 'all_season' : 'this_week'

      @miles_data = get_team_miles_data
      @long_runs_data = get_team_long_runs_data
    when 'featured'
      @featured_runs = @team.featured_runs
    when 'recent_activity'
      @recent_runs = @team.recent_runs
    end

    render partial: "teams/show/#{@tab}", locals: { team: @team, members: @members, join_requests: @join_requests }
  end

  def calendar
    @team = Team.find(params[:team_id])
    events = @team.events

    @events = events.current.order(start_date: :asc) + events.upcoming.order(start_date: :asc) + events.past.order(end_date: :desc)

    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Calendar', team_calendar_path(@team)

    year_param = params[:year] ? Date.new(params[:year].to_i) : Date.current

    start_date = year_param.beginning_of_year
    end_date = year_param.end_of_year
    @date_range = start_date..end_date

    @year = year_param.year

    runs_in_year = @team.filtered_members.flat_map do |member|
      member.runs
            .where(date: start_date..end_date)
            .map { |run| [run, @team.long_run_distance_for_user(member)] }
    end

    @data = runs_in_year
            .group_by { |run, _| run.date }
            .transform_values do |runs|
      {
        miles: runs.sum { |run, _| run.distance },
        runs: runs.size,
        long_runs: runs.count { |run, min_distance| run.distance >= min_distance }
      }
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def new
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb 'New Team', new_team_path

    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.team_memberships.create(user: current_user) # Owner is also a member
      redirect_to @team, success: "The team <b>#{@team.name}</b> was successfully created."
    else
      render :new,
             status: :unprocessable_entity,
             error: 'Team could not be created.'
    end
  end

  def edit
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Edit Team', edit_team_path(@team)
  end

  def update
    @team.photo.attach(params[:photo])
    if @team.update(team_params)
      redirect_to team_path(@team), success: 'Team was successfully updated.'
    else
      render :edit,
             status: :unprocessable_entity,
             error: 'Team could not be updated.'
    end
  end

  def destroy
    if @team.destroy
      redirect_to teams_path, success: "The team <b>#{@team.name}</b> was successfully deleted."
    else
      redirect_to @team, error: 'Unable to delete team.'
    end
  end

  def join
    eligibility_check = current_user.eligibility_for_team_membership(@team)

    unless eligibility_check[:allowed?]
      return(
        redirect_back fallback_location: teams_path,
                      alert: eligibility_check[:message]
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
         join_request&.canceled
         team_membership&.destroy
       end
      if Rails.cache.respond_to?(:delete_matched)
        Rails.cache.delete_matched("#{@team.cache_key}/members/*")
      else
        Rails.logger.warn 'Cache store does not support delete_matched'
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
      if Rails.cache.respond_to?(:delete_matched)
        Rails.cache.delete_matched("#{@team.cache_key}/members/*")
      else
        Rails.logger.warn 'Cache store does not support delete_matched'
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

  def edit_members
    @memberships = @team.team_memberships.includes(:user).sort_by { it.user.default_name.downcase }
  end

  def update_members
    @memberships = @team.team_memberships.includes(:user)

    TeamMembership.transaction do
      params[:team_memberships].each do |id, membership_params|
        membership = @memberships.find { it.id == id.to_i }

        membership_params =
          membership_params.transform_values do |value|
            %w[true false].include?(value) ? value == 'true' : value
          end

        membership.update!(
          membership_params.permit(
            :included_in_stats,
            :allowed_to_edit_goals,
            :mileage_goal,
            :long_run_goal
          )
        )
      end
    end

    # redirect_to @team, success: 'Team members updated successfully.'
    redirect_back fallback_location: @team, success: 'Team members updated successfully.'
  rescue ActiveRecord::RecordInvalid
    redirect_to edit_team_path(@team, tab: 'membersTab'), error: 'There was an error updating team members.'
  end

  def member
    @team =
      Team
      .with_attached_photo
      .includes(:team_memberships)
      .find(params[:team_id])

    @team_membership =
      @team
      .team_memberships
      .includes(user: [:runs, { avatar_attachment: { blob: :variant_records } }])
      .find_by(user_id: params[:user_id])

    return redirect_back fallback_location: @team, error: 'Member not found.' unless @team_membership

    @member = @team_membership.user

    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb @member.default_name, team_member_path(@team, @member)

    @tab = params[:tab]

    return unless @tab == 'trends' # the below data is only needed for the trends tab

    @trends_date_range_param = params[:trends_date_range] || @team.season_dates? ? 'all_season' : 'this_week'
    @group_by_param = params[:group_by] || 'day'
    @trends_date_range, @trends_date_range_description = get_trends_data

    @miles_data = get_member_miles_data
    @long_runs_data = get_member_long_runs_data
  end

  def member_tab
    @team = Team.find(params[:team_id])
    @team_membership = @team.team_memberships.find_by(user_id: params[:user_id])
    @member = @team_membership.user

    @tab = params[:tab]

    allowed_tabs = %w[member_info teams runs badges trends]
    raise ActionController::RoutingError, 'Not Found' unless allowed_tabs.include?(@tab)

    case @tab
    when 'user_info'
      @current_streak_data = @user.current_streak(@team)
      @record_streak_data = @user.record_streak(@team)
    when 'teams'
      @owned_teams = @member.owned_teams.with_attached_photo.includes(:owner)
      @membered_teams = @member.membered_teams.with_attached_photo.includes(:owner)
    when 'runs'
      @runs, @runs_date_range = get_runs_and_date_range
      @runs_date_range_param = params[:run_date_range] || 'this_week'
    when 'trends'
      @trends_date_range_param = params[:trends_date_range] || @team.season_dates? ? 'all_season' : 'this_week'
      @group_by_param = params[:group_by] || 'day'
      @trends_date_range, @trends_date_range_description = get_trends_data

      @miles_data = get_member_miles_data
      @long_runs_data = get_member_long_runs_data
    end

    path = @tab.in?(%w[teams runs]) ? 'users' : 'teams/member'

    render partial: "#{path}/#{@tab}", locals: {
      team: @team,
      team_membership: @team_membership,
      member: @member,
      user: @member,
      owned_teams: @owned_teams,
      membered_teams: @membered_teams,
      runs: @runs,
      runs_date_range: @runs_date_range
    }
  end

  def member_calendar
    @team =
      Team
      .with_attached_photo
      .includes(:team_memberships)
      .find(params[:team_id])

    @team_membership =
      @team
      .team_memberships
      .includes(:user)
      .find_by(user_id: params[:user_id])

    return redirect_back fallback_location: @team, error: 'Member not found.' unless @team_membership

    @member = @team_membership.user

    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb @member.default_name, team_member_path(@team, @member)
    add_breadcrumb 'Calendar', team_member_calendar_path(@team, @member)

    year_param = params[:year] ? Date.new(params[:year].to_i) : Date.current

    start_date = year_param.beginning_of_year
    end_date = year_param.end_of_year
    @date_range = start_date..end_date

    @year = year_param.year

    min_distance = @team.long_run_distance_for_user @member

    @data = @member.runs
                   .where(date: start_date..end_date)
                   .group_by(&:date)
                   .transform_values do |runs|
      {
        miles: runs.sum(&:distance),
        runs: runs.size,
        long_runs: runs.count { _1.distance >= min_distance }
      }
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def main_chat
    @team = Team.find(params[:team_id])
    main_topic = @team.main_chat_topic

    if main_topic
      redirect_to team_topic_messages_path(@team, main_topic)
    else
      redirect_to team_topics_path(@team), error: 'Main Chat not found.'
    end
  end

  private

  def set_team
    @team =
      Team
      .with_attached_photo
      .includes(
        :owner,
        :join_requests,
        :team_memberships,
        members: {
          avatar_attachment: {
            blob: :variant_records
          }
        }
      )
      .find(params[:id])
  end

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
    team = Team.find(params[:team_id] || params[:id])
    return if current_user.owns?(team)

    redirect_to team, alert: 'You are not authorized to perform this action.'
  end

  def authorize_member!
    team = Team.find(params[:team_id])
    return if current_user.member_of?(team)

    redirect_to team, alert: 'You are not authorized to perform this action.'
  end

  def get_members
    @members =
      if params[:query].present?
        sanitized_query = ActiveRecord::Base.connection.quote(params[:query])
        @team
          .members
          .with_attached_avatar
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
        @team.members.with_attached_avatar
      end
  end

  def get_rankings_data
    today = Date.today

    if params[:rankings_date_range].present?
      case params[:rankings_date_range]
      when 'all_season'
        [@team.season_start_date..@team.season_end_date, 'this season']
      when 'this_week'
        [today.beginning_of_week(@team.week_start)..today, 'this week']
      when 'last_week'
        one_week_ago = today - 1.week
        beginning_of_week = one_week_ago.beginning_of_week(@team.week_start)
        end_of_week = one_week_ago.end_of_week(@team.week_start)
        [beginning_of_week..end_of_week, 'last week']
      when 'this_month'
        [today.beginning_of_month..today, 'this month']
      when 'last_month'
        one_month_ago = today - 1.month
        beginning_of_month = one_month_ago.beginning_of_month
        end_of_month = one_month_ago.end_of_month
        [beginning_of_month..end_of_month, 'last month']
      when 'custom_range'
        @rankings_start_date = params[:rankings_start_date].to_date
        @rankings_end_date = params[:rankings_end_date].to_date
        [
          @rankings_start_date..@rankings_end_date,
          "from #{@rankings_start_date.strftime('%m/%d/%Y')} to #{@rankings_end_date.strftime('%m/%d/%Y')}"
        ]
      end
    elsif @team.season_dates?
      [@team.season_start_date..@team.season_end_date, 'this season']
    else
      [today.beginning_of_week(@team.week_start)..today, 'this week']
    end
  end

  def get_trends_data
    today = Date.today

    if params[:trends_date_range].present?
      case params[:trends_date_range]
      when 'all_season'
        [@team.season_start_date..@team.season_end_date, 'this season']
      when 'this_week'
        [
          week_range(current_date: today, week_start: @team.week_start),
          'this week'
        ]
      when 'last_week'
        [
          week_range(current_date: today - 1.week, week_start: @team.week_start),
          'last week'
        ]
      when 'this_month'
        [month_range(current_date: today), 'this month']
      when 'last_month'
        [month_range(current_date: today - 1.month), 'last month']
      when 'custom_range'
        @trends_start_date = params[:trends_start_date].to_date
        @trends_end_date = params[:trends_end_date].to_date

        [
          @trends_start_date..@trends_end_date,
          "from #{@trends_start_date.strftime('%m/%d/%Y')} to #{@trends_end_date.strftime('%m/%d/%Y')}"
        ]
      end
    elsif @team.season_dates?
      [@team.season_start_date..@team.season_end_date, 'this season']
    else
      [
        week_range(current_date: today, week_start: @team.week_start),
        'this week'
      ]
    end
  end

  def get_team_miles_data
    group_by = params[:group_by] || 'day'

    if group_by == 'week'
      @trends_date_range
        .group_by { |date| date.beginning_of_week(@team.week_start) }
        .map do |week_start, dates|
          [
            pretty_date(
              week_start,
              month_format: :short,
              date_style: :absolute
            ),
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
      @trends_date_range
        .group_by { |date| date.beginning_of_week(@team.week_start) }
        .map do |week_start, dates|
          [
            pretty_date(
              week_start,
              month_format: :short,
              date_style: :absolute
            ),
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
      @trends_date_range
        .group_by { |date| date.beginning_of_week(@team.week_start) }
        .map do |week_start, dates|
          [
            pretty_date(
              week_start,
              month_format: :short,
              date_style: :absolute
            ),
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
      @trends_date_range
        .group_by { |date| date.beginning_of_week(@team.week_start) }
        .map do |week_start, dates|
          [
            pretty_date(
              week_start,
              month_format: :short,
              date_style: :absolute
            ),
            dates.sum do |date|
              @member.long_runs_in_date_range(@team, date).count
            end
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

  def get_runs_and_date_range
    today = Date.today

    if params[:run_date_range].present?
      case params[:run_date_range]
      when 'this_week'
        [
          @member.runs_in_date_range(today.beginning_of_week..today),
          'this week'
        ]
      when 'last_week'
        one_week_ago = today - 1.week
        [
          @member.runs_in_date_range(
            one_week_ago.beginning_of_week..one_week_ago.end_of_week
          ),
          'last week'
        ]
      when 'this_month'
        [
          @member.runs_in_date_range(today.beginning_of_month..today),
          'this month'
        ]
      when 'last_month'
        one_month_ago = today - 1.month
        [
          @member.runs_in_date_range(
            one_month_ago.beginning_of_month..one_month_ago.end_of_month
          ),
          'last month'
        ]
      when 'custom_range'
        @run_start_date = params[:run_start_date].to_date
        @run_end_date = params[:run_end_date].to_date
        [
          @member.runs_in_date_range(@run_start_date..@run_end_date),
          "from #{@run_start_date.strftime('%m/%d/%Y')} to #{@run_end_date.strftime('%m/%d/%Y')}"
        ]
      end
    else
      [@member.runs_in_date_range(today.beginning_of_week..today), 'this week']
    end
  end
end
