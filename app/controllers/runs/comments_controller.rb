class Runs::CommentsController < ApplicationController
  before_action :set_run
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[create load_more]

  def create
    unless @run.allow_comments? || @run.user == current_user
      return(
      redirect_to run_path(@run),
                  alert: 'Comments have been disabled for this run.'
    )
    end

    @comment = @run.comments.build(comment_params.merge(user: current_user))

    respond_to do |format|
      if @comment.save
        format.turbo_stream
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'new_comment_form',
            partial: 'comments/new_form',
            locals: { comment: @comment }
          )
        end
      end
      format.html { redirect_to run_path(@run) }
    end
  end

  def load_more
    # Retrieve the timestamp of the oldest message from the front-end
    end_timestamp = params[:oldest_timestamp]

    # Prepare the base query for fetching comments older than the given timestamp
    base_query = @run.comments.active.where('created_at < ?', end_timestamp).order(created_at: :desc)

    @comments = base_query.limit(10)
                          .includes(:user, :likes, { comments: [:user, :likes, { comments: %i[user likes] }] })

    @more_comments = base_query.offset(10).exists?

    @oldest_timestamp = @comments.last&.created_at

    html = render_to_string(partial: 'comments/comments_list', locals: { comments: @comments })
    render json: { html:, more_data: @more_comments, oldest_timestamp: @oldest_timestamp }
  end

  private

  def set_run = @run = Run.find(params[:run_id])

  def comment_params = params.require(:comment).permit(:content)

  def authorize_member!
    return if current_user.any_teams_in_common?(@run.user)

    redirect_back fallback_location: run_path(@run), alert: 'You are not authorized to perform this action.'
  end
end
