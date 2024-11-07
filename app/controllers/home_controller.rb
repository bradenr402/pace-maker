class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @recent_updates = recent_updates
    @user_info = user_info
  end

  private

  def recent_updates
    any_connected_users = current_user.connected_users.any?
    any_owned_teams = current_user.owned_teams.any?

    {
      team_updates: recent_team_updates,
      new_teams: any_connected_users ? new_teams_by_connected_users : [],
      new_runs: any_connected_users ? new_runs_by_connected_users : [],
      streak_advancements: any_connected_users ? streak_advancements_by_connected_users : [],
      join_requests: any_owned_teams ? pending_join_requests : []
    }
  end

  def user_info
    {
      streak: current_user.current_streak[:streak],
      has_run_today: current_user.runs_today?
    }
  end

  # Helper methods for recent_updates

  # 1. Fetches updates to team attributes and settings for teams the user is a member of
  def recent_team_updates
    team_ids = current_user.membered_teams.pluck(:id)
    TeamAudit.where(team_id: team_ids)
             .where('changed_at >= ?', 1.week.ago)
             .order(changed_at: :desc)
  end

  # 2. Fetches new teams created by connected users (users with a team in common)
  def new_teams_by_connected_users
    Team.where(owner_id: current_user.connected_user_ids)
        .recently_created
  end

  # 3. Fetches new runs by connected users
  def new_runs_by_connected_users
    Run.recent_by_connected_users(current_user)
       .includes(user: :avatar_attachment)
  end

  # 4. Fetches recent streak advancements by connected users
  def streak_advancements_by_connected_users
    current_user.connected_users
                .map { |user| user.current_streak.merge(user: user) }
                .select { |streak| streak[:streak] >= 2 }
                .map do |streak|
      {
        user: streak[:user],
        streak: streak[:streak],
        start_date: streak[:start_date],
        end_date: streak[:end_date]
      }
    end
  end

  # 5. Fetches pending join requests for teams the current user owns  def pending_join_requests
  def pending_join_requests
    TeamJoinRequest.where(team_id: current_user.owned_team_ids, status: :pending)
                   .order(created_at: :desc)
                   .includes(:team, user: :avatar_attachment)
  end
end
