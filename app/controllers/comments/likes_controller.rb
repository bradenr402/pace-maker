class Comments::LikesController < ApplicationController
  before_action :set_comment
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[create]

  def create
    @comment.likes.create(user: current_user)
    render_like_count
  end

  def destroy
    @comment.likes.find_by(user: current_user)&.destroy
    render_like_count
  end

  private

  def set_comment = @comment = Comment.find(params[:comment_id])

  def render_like_count
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: run_path(@run) }
    end
  end

  def authorize_member!
    comment = Comment.find(params[:comment_id])

    return if comment.parent_run.user == current_user || current_user.any_teams_in_common?(comment.parent_run.user)

    redirect_back fallback_location: comment, alert: 'You are not authorized to perform this action.'
  end
end
