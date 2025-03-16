class Runs::LikesController < ApplicationController
  before_action :set_run
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[create]

  def create
    @run.likes.create(user: current_user)
    render_like_count
  end

  def destroy
    @run.likes.find_by(user: current_user)&.destroy
    render_like_count
  end

  private

  def render_like_count
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: run_path(@run) }
    end
  end

  def set_run = @run = Run.find(params[:run_id])

  def authorize_member!
    return if @run.user == current_user || current_user.any_teams_in_common?(@run.user)

    redirect_back fallback_location: run_path(@run), alert: 'You are not authorized to perform this action.'
  end
end
