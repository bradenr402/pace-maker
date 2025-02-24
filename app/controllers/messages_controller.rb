class MessagesController < ApplicationController
  before_action :set_team
  before_action :set_topic
  before_action :set_message, only: %i[edit update destroy pin unpin cancel_edit]
  before_action :authenticate_user!
  before_action :authorize_member!
  before_action :authorize_owner!, only: %i[pin unpin]

  def index
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Topics', team_topics_path(@team)
    add_breadcrumb @topic.title, team_topic_path(@team, @topic)

    @messages = @topic.messages.includes(:user, :likes).order(created_at: :asc).limit(100)
    @pinned_message = @messages.find_by(pinned: true)

    update_last_read
  end

  def create
    if @topic.closed?
      return redirect_to team_topic_messages_path(@team, @topic),
                         alert: 'This topic is closed. You cannot add new messages.'
    end

    @message = @topic.messages.build(message_params.merge(user: current_user))

    respond_to do |format|
      if @message.save
        update_last_read # needs to be called after the message is saved, so this message ism't marked unread
        format.turbo_stream
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'new_message_form',
            partial: 'messages/form',
            locals: { message: @message, topic: @topic }
          )
        end
      end
      format.html { redirect_to team_topic_messages_path(@team, @topic) }
    end
  end

  def edit
    update_last_read
    if @message.pinned? && !@message.user.owns?(@team)
      return redirect_to team_topic_messages_path(@team, @topic), alert: 'You cannot edit a pinned message.'
    end

    unless @message.editable?
      return redirect_to team_topic_messages_path(@team, @topic), alert: 'You cannot edit this message.'
    end

    @pin = params[:pinned] == 'true'

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to team_topic_messages_path(@team, @topic), error: 'Message could not be edited.' }
    end
  end

  def update
    update_last_read
    if @message.pinned? && !@message.user.owns?(@team)
      return redirect_to team_topic_messages_path(@team, @topic), alert: 'You cannot edit a pinned message.'
    end

    unless @message.editable?
      return redirect_to team_topic_messages_path(@team, @topic), alert: 'You cannot edit this message.'
    end

    if @message.update(content: params[:message][:content])
      respond_to do |format|
        format.turbo_stream { flash.now[:success] = 'Message updated successfully.' }
        format.html { redirect_to team_topic_messages_path(@team, @topic), success: 'Message updated successfully.' }
      end
    else
      redirect_to team_topic_messages_path(@team, @topic), error: 'Message could not be updated.'
    end
  end

  def destroy
    update_last_read
    unless (@message.user == current_user && @message.deletable?) || current_user.owns?(@team)
      return redirect_to team_topic_messages_path(@team, @topic), alert: 'You cannot delete this message.'
    end

    if @message.update(content: Message.deleted_text, deleted_at: Time.current, pinned: false)
      respond_to do |format|
        format.turbo_stream { flash.now[:success] = 'Message deleted.' }
        format.html { redirect_to team_topic_messages_path(@team, @topic), success: 'Message deleted.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:error] = 'Message could not be deleted.' }
        format.html { redirect_to team_topic_messages_path(@team, @topic), error: 'Message could not be deleted.' }
      end
    end
  end

  def pin
    update_last_read
    if @topic.closed?
      return redirect_to team_topic_messages_path(@team, @topic),
                         alert: 'This topic is closed. You cannot pin messages.'
    end

    return redirect_to team_topic_messages_path(@team, @topic), notice: 'Message already pinned.' if @message.pinned?

    if @message.deleted?
      return respond_to do |format|
        @invalid_pin_attempt = true
        format.turbo_stream { flash.now[:alert] = 'You cannot pin a deleted message.' }
        format.html { redirect_to team_topic_messages_path(@team, @topic), alert: 'You cannot pin a deleted message.' }
      end
    end

    @previous_pinned_message = @topic.pinned_message
    @previous_pinned_message&.unpin!
    @message.pin!

    respond_to do |format|
      format.turbo_stream { flash.now[:success] = 'Message pinned.' }
      format.html { redirect_to team_topic_messages_path(@team, @topic), success: 'Message pinned.' }
    end
  end

  def unpin
    update_last_read
    @message.unpin!

    redirect_to team_topic_messages_path(@team, @topic), success: 'Message unpinned.'
  end

  def cancel_edit
    update_last_read
    @pin = params[:pinned] == 'true'

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to team_topic_messages_path(@team, @topic) }
    end
  end

  private

  def set_team = @team = Team.find(params[:team_id])

  def set_topic = @topic = @team.topics.find(params[:topic_id])

  def set_message = @message = @topic.messages.find(params[:id])

  def message_params = params.require(:message).permit(:content, :parent_id)

  def authorize_owner!
    return if current_user.owns?(@team)

    redirect_to team_topic_messages_path(@team, @topic), alert: 'Only the team owner can pin and unpin messages.'
  end

  def authorize_member!
    return if current_user.member_of?(@team)

    redirect_to team_path(@team),
                alert: 'You are not authorized to perform this action.'
  end

  def update_last_read
    user_topic = current_user.user_topics.find_or_initialize_by(topic: @topic)

    user_topic.update_last_read
  end
end
