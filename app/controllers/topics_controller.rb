class TopicsController < ApplicationController
  before_action :set_team
  before_action :set_topic, only: %i[edit update destroy close reopen]
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[index]
  before_action :authorize_owner!, only: %i[edit update close reopen]

  def index
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Topics', team_topics_path(@team)

    @topics = @team.topics.open.sort_by { _1.last_message.created_at }.reverse
    @closed_topics = @team.topics.closed.sort_by { _1.last_message.created_at }.reverse
  end

  def create
    @topic = @team.topics.build(topic_params)
    @topic.main = false

    if @topic.save
      flash[:success] = 'Topic was successfully created.'
    else
      flash[:error] = 'Topic could not be created.'
    end
    redirect_to team_topics_path(@team)
  end

  def edit; end

  def update
    if @topic.update(topic_params)
      flash[:success] = 'Topic was successfully updated.'
    else
      flash[:error] = 'Topic could not be updated.'
    end
    redirect_to team_topics_path(@team)
  end

  def destroy
    if @topic.destroy
      redirect_to team_topics_path(@team), success: 'Topic was successfully deleted.'
    else
      redirect_to team_topics_path(@team), error: 'Topic could not be deleted.'
    end
  end

  def close
    return redirect_to team_topics_path(@team), notice: 'Topic is already closed.' if @topic.closed?

    return redirect_to team_topics_path(@team), alert: 'You cannot close the Main Chat.' if @topic.main

    if @topic.close
      redirect_to team_topics_path(@team), success: 'Topic was successfully closed.'
    else
      redirect_to team_topics_path(@team), error: 'Topic could not be closed.'
    end
  end

  def reopen
    return redirect_to team_topics_path(@team), notice: 'Topic is already open.' if @topic.open?

    if @topic.reopen
      redirect_to team_topics_path(@team), success: 'Topic was successfully reopened.'
    else
      redirect_to team_topics_path(@team), error: 'Topic could not be reopened.'
    end
  end

  private

  def set_team = @team = Team.find(params[:team_id])

  def set_topic = @topic = @team.topics.find(params[:id])

  def topic_params = params.require(:topic).permit(:title)

  def authorize_owner!
    return if current_user.owner_of?(@team)

    redirect_to team_topics_path(@team),
                alert: 'You are not authorized to peform this action.'
  end

  def authorize_member!
    return if current_user.member_of?(@team)

    redirect_to team_path(@team),
                alert: 'You are not authorized to perform this action.'
  end
end
