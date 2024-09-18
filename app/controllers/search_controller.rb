class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:query]
    @teams = @query.present? ? search_teams : []
    @users = @query.present? ? search_users : []

    @results = (@teams + @users).sort_by { |result| -result.similarity_score }

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def sanitized_query = ActiveRecord::Base.connection.quote(@query)

  def search_teams
    Team
      .joins(:owner)
      .where(
        'LOWER(teams.name) LIKE LOWER(:query) OR
        LOWER(users.username) LIKE LOWER(:query) OR
        LOWER(users.display_name) LIKE LOWER(:query) OR
        similarity(teams.name, :query) > 0.3 OR
        similarity(users.username, :query) > 0.3 OR
        similarity(users.display_name, :query) > 0.3',
        query: "%#{@query}%"
      )
      .select(
        "teams.*, users.username, users.display_name,
               GREATEST(similarity(teams.name, #{sanitized_query}),
                        similarity(users.username, #{sanitized_query}),
                        similarity(users.display_name, #{sanitized_query}),
                        CASE
                          WHEN LOWER(teams.name) LIKE LOWER(#{sanitized_query})
                          THEN 1
                          ELSE 0
                        END) AS similarity_score"
      )
      .order('similarity_score DESC')
  end

  def search_users
    User
      .joins(:teams)
      .where(
        'teams.id IN (?) OR teams.owner_id = ?',
        current_user.teams.pluck(:id),
        current_user.id
      )
      .where(
        'LOWER(users.username) LIKE LOWER(:query) OR
        LOWER(users.display_name) LIKE LOWER(:query) OR
        similarity(users.username, :query) > 0.3 OR
        similarity(users.display_name, :query) > 0.3',
        query: "%#{@query}%"
      )
      .select(
        "users.*,
               GREATEST(similarity(users.username, #{sanitized_query}),
                        similarity(users.display_name, #{sanitized_query}),
                        CASE
                          WHEN LOWER(users.username) LIKE LOWER(#{sanitized_query})
                          THEN 1
                          ELSE 0
                        END) AS similarity_score"
      )
      .order('similarity_score DESC')
      .distinct
  end
end
