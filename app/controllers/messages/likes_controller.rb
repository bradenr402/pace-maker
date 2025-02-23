class Messages::LikesController < ApplicationController
  before_action :set_message
  before_action :authenticate_user!
  before_action :authorize_member!

  def create
    @message.likes.create(user: current_user)
    render_like_count
  end

  def destroy
    @message.likes.find_by(user: current_user)&.destroy
    render_like_count
  end

  private

  def set_message
    @message = Message.find(params[:message_id])
  end

  def render_like_count
    flash.now[:notice] = "Liked message. Message: #{@message.id}, Likes: #{@message.like_count}, Content: #{@message.content}"

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: team_messages_path(@message.team) }
    end
  end

  def authorize_member!
    return if current_user.member_of?(@message.team)

    redirect_to team_path(@message.team),
                alert: 'You are not authorized to acccess this page.'
  end
end
