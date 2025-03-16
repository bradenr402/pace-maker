class Comments::CommentsController < ApplicationController
  before_action :set_parent
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[create]

  def create
    @comment = @parent.comments.build(comment_params.merge(user: current_user))

    respond_to do |format|
      if @parent.save
        format.turbo_stream
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'new_comment_form',
            partial: 'comments/new_form',
            locals: { comment: @comment.parent_run.comments.new }
          )
        end
      end
      format.html { redirect_to run_path(@comment.parent_run) }
    end
  end

  private

  def set_parent = @parent = Comment.find(params[:comment_id])

  def comment_params = params.require(:comment).permit(:content)

  def authorize_member!
    comment = Comment.find(params[:comment_id])

    return if comment.parent_run.user == current_user || current_user.any_teams_in_common?(comment.parent_run.user)

    redirect_back fallback_location: comment, alert: 'You are not authorized to perform this action.'
  end
end
