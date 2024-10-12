class TeamsController < ApplicationController
  include DateHelper

  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy join leave]
  before_action :authorize_owner!, only: %i[remove_member]

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

    query_param = params[:query]
    @other_teams =
      if query_param.present?
        sanitized_query = ActiveRecord::Base.connection.quote(query_param)
        Team
          .with_attached_photo
          .includes(:owner, :setting_objects, :members)
          .joins(:owner)
          .where(
            'LOWER(teams.name) LIKE LOWER(:query) OR
            LOWER(users.username) LIKE LOWER(:query) OR
            LOWER(users.display_name) LIKE LOWER(:query) OR
            similarity(teams.name, :query) > 0.3 OR
            similarity(users.username, :query) > 0.3 OR
            similarity(users.display_name, :query) > 0.3',
            query: "%#{query_param}%"
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
        current_user.other_teams.with_attached_photo.includes(
          :owner,
          :setting_objects,
          :members
        )
      end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)

    @members =
      Rails
      .cache
      .fetch([@team, 'members', params[:query]], expires_in: 1.hour) do
        get_members
      end

    @rankings_date_range, @rankings_date_range_description =
      Rails
      .cache
      .fetch([@team, 'rankings_data'], expires_in: 1.hour) do
        get_rankings_data
      end

    @trends_date_range, @trends_date_range_description =
      Rails
      .cache
      .fetch([@team, 'trends_data'], expires_in: 1.hour) { get_trends_data }

    @miles_data =
      Rails
      .cache
      .fetch([@team, 'miles_data', @trends_date_range], expires_in: 1.hour) do
        get_team_miles_data
      end

    @long_runs_data =
      Rails
      .cache
      .fetch(
        [@team, 'long_runs_data', @trends_date_range],
        expires_in: 1.hour
      ) { get_team_long_runs_data }

    if current_user.owns?(@team)
      @join_requests =
        @team
        .join_requests
        .includes(user: :avatar_attachment)
        .pending
        .order(updated_at: :desc)

      @current_user_owns_team = true
    end

    if current_user.member_of?(@team)
      @current_user_member_of_team = true
      @featured_runs =
        Rails
        .cache
        .fetch([@team, 'featured_runs'], expires_in: 1.hour) do
          @team.featured_runs
        end

      @recent_runs =
        Rails
        .cache
        .fetch([@team, 'recent_runs'], expires_in: 1.hour) do
          @team.recent_runs
        end

      @all_members =
        @team
        .members
        .with_attached_avatar
        .includes(:runs)
        .map do |member|
          {
            member:,
            total_miles: member.miles_in_date_range(@rankings_date_range),
            total_long_runs:
              member.total_long_runs_in_date_range(
                @team,
                @rankings_date_range
              ),
            current_streak: member.current_streak(@team)[:streak],
            longest_streak: member.longest_streak(@team)[:streak]
          }
        end
    end

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
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb 'New team', new_team_path

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

  def edit
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Edit team', edit_team_path(@team)
  end

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

    @trends_date_range, @trends_date_range_description =
      Rails
      .cache
      .fetch(
        "#{@team.cache_key}/#{@member.cache_key}/trends_data",
        expires_in: 1.hour
      ) { get_trends_data }

    @miles_data =
      Rails
      .cache
      .fetch(
        "#{@team.cache_key}/#{@member.cache_key}/miles_data",
        expires_in: 1.hour
      ) { get_member_miles_data }

    @long_runs_data =
      Rails
      .cache
      .fetch(
        "#{@team.cache_key}/#{@member.cache_key}/long_runs_data",
        expires_in: 1.hour
      ) { get_member_long_runs_data }

    @runs_by_date =
      @member.runs_in_date_range(@team.season_range).group_by(&:date)

    @long_runs_by_date =
      @member.long_runs_in_date_range(@team, @team.season_range).group_by(
        &:date
      )
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
    team = Team.find(params[:team_id])
    return if current_user.owns?(team)

    redirect_to team, alert: 'You are not authorized to perform this action.'
  end

  def get_members
    @members ||=
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
    if @rankings_date_range.present? && @rankings_date_range_description.present?
      return @rankings_date_range, @rankings_date_range_description
    end

    if params[:rankings_date_range].present?
      today = Date.today

      case params[:rankings_date_range]
      when 'All season'
        [@team.season_start_date..@team.season_end_date, 'this season']
      when 'This week'
        [today.beginning_of_week(@team.week_start)..today, 'this week']
      when 'Last week'
        one_week_ago = today - 1.week
        beginning_of_week = one_week_ago.beginning_of_week(@team.week_start)
        end_of_week = one_week_ago.end_of_week(@team.week_start)
        [beginning_of_week..end_of_week, 'last week']
      when 'This month'
        [today.beginning_of_month..today, 'this month']
      when 'Last month'
        one_month_ago = today - 1.month
        beginning_of_month = one_month_ago.beginning_of_month
        end_of_month = one_month_ago.end_of_month
        [beginning_of_month..end_of_month, 'last month']
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

  def get_trends_data
    if @trends_date_range.present? && @trends_date_range_description.present?
      return @trends_date_range, @trends_date_range_description
    end

    today = Date.today

    if params[:trends_date_range].present?
      case params[:trends_date_range]
      when 'All season'
        [@team.season_start_date..@team.season_end_date, 'this season']
      when 'This week'
        [
          week_range(current_date: today, week_start: @team.week_start),
          'this week'
        ]
      when 'Last week'
        [
          week_range(current_date: today - 1.week, week_start: @team.week_start),
          'last week'
        ]
      when 'This month'
        [month_range(current_date: today), 'this month']
      when 'Last month'
        [month_range(current_date: today - 1.month), 'last month']
      when 'Custom range'
        start_date = params[:trends_start_date].to_date
        end_date = params[:trends_end_date].to_date

        [
          start_date..end_date,
          "between #{format_date(start_date, separator: '.')} and #{format_date(end_date, separator: '.')}"
        ]
      end
    else
      [
        week_range(current_date: today, week_start: @team.week_start),
        'this week'
      ]
    end
  end

  def get_team_miles_data
    group_by = params[:group_by] || 'day'

    @miles_data ||=
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

    @long_runs_data ||=
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

    @miles_data ||=
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

    @long_runs_data ||=
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
end
