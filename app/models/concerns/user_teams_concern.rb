module UserTeamsConcern
  extend ActiveSupport::Concern

  def connected_users
    Rails.cache.fetch("#{cache_key_with_version}/connected_users") do
      User.joins(teams: :team_memberships)
          .where(team_memberships: { team_id: membered_teams.pluck(:id) })
          .where.not(id:)
          .distinct
    end
  end

  def connected_user_ids
    Rails.cache.fetch("#{cache_key_with_version}/connected_user_ids") do
      connected_users.pluck(:id)
    end
  end

  def owns?(team) = self == team.owner
  alias owner_of? owns?

  def member_of?(team) = teams.include?(team)

  def membered_teams = teams.where.not(owner_id: id)

  def other_teams =
    Team.not_included_in(teams.pluck(:id) + owned_teams.pluck(:id))

  def included_in_stats?(team)
    membership = team.team_memberships.find_by(user_id: id)
    membership.included_in_stats?
  end

  def excluded_from_stats?(team) = !included_in_stats?(team)

  def allowed_to_edit_goals?(team)
    membership = team.team_memberships.find_by(user_id: id)
    membership.allowed_to_edit_goals?
  end

  def search_teams(query)
    Team
      .joins(:owner)
      .where(
        'LOWER(teams.name) LIKE LOWER(:query) OR
        LOWER(users.username) LIKE LOWER(:query) OR
        LOWER(users.display_name) LIKE LOWER(:query) OR
        similarity(teams.name, :query) > 0.3 OR
        similarity(users.username, :query) > 0.3 OR
        similarity(users.display_name, :query) > 0.3',
        query: "%#{query}%"
      )
      .select(
        ActiveRecord::Base.sanitize_sql_array([
                                                "teams.*, users.username, users.display_name,
                                                GREATEST(similarity(teams.name, ?),
                                                          similarity(users.username, ?),
                                                          similarity(users.display_name, ?),
                                                          CASE
                                                            WHEN LOWER(teams.name) LIKE LOWER(?)
                                                            THEN 1
                                                            ELSE 0
                                                          END) AS similarity_score",
                                                query, query, query, "%#{query}%"
                                              ])
      )
      .order('similarity_score DESC')
  end

  def search_users(query)
    connected_users
      .where(
        'LOWER(users.username) LIKE LOWER(:query) OR
        LOWER(users.display_name) LIKE LOWER(:query) OR
        similarity(users.username, :query) > 0.3 OR
        similarity(users.display_name, :query) > 0.3',
        query: "%#{query}%"
      )
      .select(
        ActiveRecord::Base.sanitize_sql_array([
                                                "users.*,
                                                GREATEST(similarity(users.username, ?),
                                                          similarity(users.display_name, ?),
                                                          CASE
                                                            WHEN LOWER(users.username) LIKE LOWER(?)
                                                            THEN 1
                                                            ELSE 0
                                                          END) AS similarity_score",
                                                query, query, "%#{query}%"
                                              ])
      )
      .order('similarity_score DESC')
      .distinct
  end

  def eligibility_for_team_membership(team)
    return ineligible_message('Team not found.') if team.nil?

    return ineligible_message('You are the owner of this team.') if owns?(team)

    return ineligible_message('You are already a member of this team.') if member_of?(team)

    existing_request = TeamJoinRequest.find_by(user: self, team:)
    return ineligible_message('You have already requested to join this team.') if existing_request&.pending?

    return ineligible_message('You have been blocked from joining this team.') if existing_request&.blocked?

    unless team.gender_requirement_met?(self)
      return ineligible_message('You must specify your gender to join this team.')
    end

    { allowed?: true, message: 'You meet the requirements to join this team.' }
  end

  def teams_requiring_gender =
    teams.includes(:setting_objects).select(&:require_gender?)

  def any_teams_require_gender? = teams_requiring_gender.any?

  def teams_in_common(other_user) =
    Rails.cache.fetch([cache_key_with_version, other_user.cache_key_with_version, 'teams_in_common']) do
      teams.select { |team| other_user.teams.include?(team) }
    end

  def any_teams_in_common?(other_user) = teams_in_common(other_user).any?

  def no_teams_in_common?(other_user) = teams_in_common(other_user).blank?

  def owned_teams_in_common(other_user) =
    Rails.cache.fetch([cache_key_with_version, other_user.cache_key_with_version, 'owned_teams_in_common']) do
      owned_teams.select { |team| other_user.teams.include?(team) }
    end

  def any_owned_teams_in_common?(other_user) =
    owned_teams_in_common(other_user).any?

  def membered_teams_in_common(other_user) =
    Rails.cache.fetch([cache_key_with_version, other_user.cache_key_with_version, 'membered_teams_in_common']) do
      membered_teams.select { |team| other_user.teams.include?(team) }
    end

  def any_membered_teams_in_common?(other_user) =
    membered_teams_in_common(other_user).any?

  def membered_teams_in_common_except(other_user, exclude: [])
    Rails.cache.fetch([cache_key_with_version, other_user.cache_key_with_version, 'membered_teams_in_common_except']) do
      membered_teams
        .select { |team| other_user.membered_teams.include?(team) }
        .reject { |team| exclude.include?(team) }
    end
  end

  def any_membered_teams_in_common_except?(other_user, exclude: []) =
    membered_teams_in_common_except(other_user, exclude:).any?
end
