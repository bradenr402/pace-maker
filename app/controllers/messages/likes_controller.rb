class Messages::LikesController < ApplicationController
  before_action :set_topic
  before_action :set_message
  before_action :authenticate_user!
  before_action :authorize_member!
  after_action :update_last_read

  def create
    if @topic.closed?
      redirect_to team_topic_messages_path(@topic.team, @topic), alert: 'This topic is closed. You cannot like messages.'
    end

    @message.likes.create(user: current_user)
    render_like_count
  end

  def destroy
    if @topic.closed?
      redirect_to team_topic_messages_path(@topic.team, @topic), alert: 'This topic is closed. You cannot unlike messages.'
    end

    @message.likes.find_by(user: current_user)&.destroy
    render_like_count
  end

  private

  def set_topic = @topic = Topic.find(params[:topic_id])

  def set_message = @message = @topic.messages.find(params[:message_id])

  def render_like_count
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: team_topic_messages_path(@message.team, @message.topic) }
    end
  end

  def authorize_member!
    return if current_user.member_of?(@message.team)

    redirect_to team_path(@message.team),
                alert: 'You are not authorized to acccess this page.'
  end

  def update_last_read
    user_topic = current_user.user_topics.find_or_initialize_by(topic: @topic)

    user_topic.update_last_read
  end
end
