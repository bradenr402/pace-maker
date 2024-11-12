class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    add_breadcrumb 'Search', search_path

    @query = params[:query]
    @teams = @query.present? ? current_user.search_teams(sanitized_query) : []
    @users = @query.present? ? current_user.search_users(sanitized_query) : []

    @results = (@teams + @users).sort_by { |result| -result.similarity_score }

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def sanitized_query = @sanitized_query ||= ActiveRecord::Base.connection.quote(@query)
end
