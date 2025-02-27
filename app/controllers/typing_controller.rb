class TypingController < ApplicationController
  before_action :set_topic
  before_action :authenticate_user!

  def update
    user_id = params.require(:user_id)
    typing = params.require(:typing)

    user = User.find(user_id)

    @topic.broadcast_typing_indicator(user, typing)

    head :ok
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end
end
