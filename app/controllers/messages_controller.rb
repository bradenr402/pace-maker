class MessagesController < ApplicationController
  before_action :set_team
  before_action :set_message, only: %i[edit update destroy pin unpin cancel_edit]
  before_action :authenticate_user!
  before_action :authorize_member!
  before_action :authorize_owner!, only: %i[pin unpin]

  def index
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Team Chat', team_messages_path(@team)

    @messages = @team.messages.includes(:user, :likes).order(created_at: :asc).limit(100)
  end

  def create
    @message = @team.messages.build(message_params.merge(user: current_user))

    respond_to do |format|
      if @message.save
        format.turbo_stream
        format.html { redirect_to team_messages_path(@team) }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'new_message_form',
            partial: 'messages/form',
            locals: { message: @message }
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    if @message.pinned? && !@message.user.owns?(@team)
      redirect_to team_messages_path(@team), error: 'You cannot edit a pinned message.'
      return
    end

    unless @message.editable?
      redirect_to team_messages_path(@team), error: 'You cannot edit this message.'
      return
    end

    @pin = params[:pinned] == 'true'

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to team_messages_path(@team), error: 'Message could not be edited.' }
    end
  end

  def update
    if @message.pinned? && !@message.user.owns?(@team)
      redirect_to team_messages_path(@team), error: 'You cannot edit a pinned message.'
      return
    end

    unless @message.editable?
      redirect_to team_messages_path(@team), error: 'You cannot edit this message.'
      return
    end

    if @message.update(content: params[:message][:content])
      respond_to do |format|
        format.turbo_stream { flash.now[:success] = 'Message updated successfully.' }
        format.html { redirect_to team_messages_path(@team), success: 'Message updated successfully.' }
      end
    else
      redirect_to team_messages_path(@team), error: 'Message could not be updated.'
    end
  end

  def destroy
    unless (@message.user == current_user && @message.deletable?) || current_user.owns?(@team)
      redirect_to team_messages_path(@team), 'You cannot delete this message.'
      return
    end

    if @message.update(content: Message.deleted_text, deleted_at: Time.current, pinned: false)
      respond_to do |format|
        format.turbo_stream { flash.now[:success] = 'Message deleted.' }
        format.html { redirect_to team_messages_path, success: 'Message deleted.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:error] = 'Message could not be deleted.' }
        format.html { redirect_to team_messages_path, error: 'Message could not be deleted.' }
      end
    end
  end

  def pin
    if @message.deleted?
      return respond_to do |format|
        @invalid_pin_attempt = true
        format.turbo_stream { flash.now[:error] = 'You cannot pin a deleted message.' }
        format.html { redirect_to team_messages_path(@message.team), error: 'You cannot pin a deleted message.' }
      end
    end

    @previous_pinned_message = @team.pinned_message
    @previous_pinned_message&.unpin!
    @message.pin!

    respond_to do |format|
      format.turbo_stream { flash.now[:success] = 'Message pinned.' }
      format.html { redirect_to team_messages_path(@message.team), success: 'Message pinned.' }
    end
  end

  def unpin
    @message.unpin!

    redirect_to team_messages_path(@message.team), success: 'Message unpinned successfully.'
  end

  def cancel_edit
    @pin = params[:pinned] == 'true'

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to team_messages_path(@team) }
    end
  end

  private

  def set_team = @team = Team.find(params[:team_id])

  def set_message = @message = Message.find(params[:id])

  def message_params = params.require(:message).permit(:content, :parent_id)

  def authorize_owner!
    return if current_user.owns?(@message.team)

    redirect_to @message.team, alert: 'Only the team owner can pin messages.'
  end

  def authorize_member!
    return if current_user.member_of?(@team)

    redirect_to team_path(@team),
                alert: 'You are not authorized to acccess this page.'
  end
end
