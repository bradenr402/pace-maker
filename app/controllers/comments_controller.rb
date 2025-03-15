class CommentsController < ApplicationController
  before_action :set_comment
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[show]

  def show
    parent = @comment

    until parent.is_a? Run
      prepend_breadcrumb("Comment by #{parent.author_name}", comment_path(parent))
      parent = parent.commentable
    end

    prepend_breadcrumb "#{parent.distance} mi run by #{parent.user.default_name}", run_path(parent)
    prepend_breadcrumb 'Runs', user_path(parent.user, tab: 'runsTab')
    prepend_breadcrumb parent.user.default_name, user_path(parent.user)

    @likes = @comment.likes.includes(:user).where.not(user: nil)
  end

  def edit
    return redirect_to run_path(@comment.parent_run), alert: 'You cannot edit this comment.' unless @comment.editable?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(@comment.parent_run), error: 'Comment could not be edited.' }
    end
  end

  def update
    return redirect_to run_path(@comment.parent_run), alert: 'You cannot edit this comment.' unless @comment.editable?

    if @comment.update(content: params[:comment][:content])
      respond_to do |format|
        format.turbo_stream { flash.now[:success] = 'Comment updated successfully.' }
        format.html { redirect_to run_path(@comment.parent_run), success: 'Comment updated successfully.' }
      end
    else
      redirect_to run_path(@comment.parent_run), error: 'Comment could not be updated.'
    end
  end

  def destroy
    if @comment.soft_delete
      flash[:success] = 'Comment deleted.'
    else
      flash[:error] = 'Comment could not be deleted.'
    end

    redirect_back fallback_location: run_path(@comment.parent_run)
  end

  def cancel_edit
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(@comment.parent_run) }
    end
  end

  def reply
    respond_to do |format|
      format.turbo_stream { render 'comments/reply' }
      format.html { redirect_to run_path(@comment.parent_run) }
    end
  end

  def cancel_reply
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to run_path(@comment.parent_run) }
    end
  end

  private

  def set_comment = @comment = Comment.find(params[:id])

  def authorize_member!
    comment = Comment.find(params[:id])

    return if current_user.any_teams_in_common?(comment.parent_run.user)

    redirect_back fallback_location: comment, alert: 'You are not authorized to perform this action.'
  end
end
