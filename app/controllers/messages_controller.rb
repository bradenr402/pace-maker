class MessagesController < ApplicationController
  before_action :set_team
  before_action :set_topic
  before_action :set_message, only: %i[show edit update destroy pin unpin cancel_edit]
  before_action :authenticate_user!
  before_action :authorize_member!
  before_action :authorize_owner!, only: %i[pin unpin]
  after_action :update_last_read

  def index
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Topics', team_topics_path(@team)
    add_breadcrumb @topic.title, team_topic_path(@team, @topic)

    @messages = @topic.messages.includes(:user, :likes).order(created_at: :desc).limit(50)
    @oldest_timestamp = @messages.last&.created_at
    @more_messages = @messages.size >= 50
    @pinned_message = @messages.find_by(pinned: true)

    @messages = @messages.first(50)

    @objects = if @topic == @team.main_chat_topic
                 topics = @team.topics
                               .where(main: false)
                               .where.not(id: @topic.id)
                               .where('created_at > ?', @oldest_timestamp)
                 team_memberships = @team.team_memberships.includes(:user)
                                         .where('created_at > ?', @oldest_timestamp)
                 (team_memberships + topics + @messages).sort_by(&:created_at)
               else
                 @messages = @messages.sort_by(&:created_at)
               end
  end

  def load_more
    end_timestamp = params[:oldest_message_timestamp]
    @messages = @topic.messages
                      .where('created_at < ?', end_timestamp)
                      .includes(:user, :likes)
                      .order(created_at: :desc)
                      .limit(50)

    @oldest_timestamp = @messages.last&.created_at
    more_messages = @messages.size >= 50
    @messages = @messages.first(50)

    @objects = if @topic == @team.main_chat_topic
                 topics = @team.topics
                               .where(main: false)
                               .where.not(id: @topic.id)
                               .where(
                                 'created_at BETWEEN ? AND ?',
                                 @oldest_timestamp,
                                 end_timestamp
                               )
                 team_memberships = @team.team_memberships.includes(:user)
                                         .where(
                                           'created_at BETWEEN ? AND ?',
                                           @oldest_timestamp,
                                           end_timestamp
                                         )
                 (team_memberships + topics + @messages).sort_by(&:created_at)
               else
                 @messages = @messages.sort_by(&:created_at)
               end

    html = render_to_string(partial: 'messages/messages_list', locals: { objects: @objects, topic: @topic })
    render json: { html:, more_messages:, oldest_timestamp: @oldest_timestamp }
  end

  def show
    @users_read_list = []
    @users_liked_list = []

    @team.members.each do |user|
      next if user == current_user

      user_topic = @topic.user_topics.find_by(user:)

      @users_read_list << user if user_topic&.last_read_at&.after?(@message.created_at)

      like = @message.likes.find_by(user:)

      @users_liked_list << user if like.present?
    end

    @users_read_list.sort_by!(&:default_name)
    @users_liked_list.sort_by!(&:default_name)
  end

  def create
    if @topic.closed?
      return redirect_to team_topic_messages_path(@team, @topic),
                         alert: 'This topic is closed. You cannot add new messages.'
    end

    @message = @topic.messages.build(message_params.merge(user: current_user))

    respond_to do |format|
      if @message.save
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
    @message.pin!

    respond_to do |format|
      format.turbo_stream { flash.now[:success] = 'Message pinned.' }
      format.html { redirect_to team_topic_messages_path(@team, @topic), success: 'Message pinned.' }
    end
  end

  def unpin
    @message.unpin!

    respond_to do |format|
      format.turbo_stream { flash.now[:success] = 'Message unpinned.' }
      format.html { redirect_to team_topic_messages_path(@team, @topic), success: 'Message unpinned.' }
    end
  end

  def cancel_edit
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
