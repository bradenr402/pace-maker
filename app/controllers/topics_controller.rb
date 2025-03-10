class TopicsController < ApplicationController
  before_action :set_team
  before_action :set_topic, only: %i[edit update destroy close reopen favorite unfavorite update_last_read]
  before_action :authenticate_user!
  before_action :authorize_member!, only: %i[index favorite unfavorite]
  before_action :authorize_owner!, only: %i[edit update close reopen]

  def index
    add_breadcrumb 'Teams', teams_path
    add_breadcrumb @team.name, team_path(@team)
    add_breadcrumb 'Topics', team_topics_path(@team)

    all_topics = @team.topics

    @open_topics = sort_topics(all_topics.open.reject { _1.favorited_by? current_user })
    @closed_topics = sort_topics(all_topics.closed)
    @favorite_topics = sort_topics(current_user.favorite_topics(@team))
  end

  def create
    @topic = @team.topics.build(topic_params)
    @topic.main = false

    if @topic.save
      flash[:success] = "#{@topic.title} topic was successfully created."
    else
      flash[:error] = "#{@topic.title} topic could not be created."
    end
    redirect_to team_topics_path(@team)
  end

  def edit; end

  def update
    if @topic.update(topic_params)
      flash[:success] = "#{@topic.title} topic was successfully updated."
    else
      flash[:error] = "#{@topic.title} topic could not be updated."
    end
    redirect_to team_topics_path(@team)
  end

  def destroy
    if @topic.destroy
      flash[:success] = "#{@topic.title} topic was successfully deleted."
    else
      flash[:error] = "#{@topic.title} topic could not be deleted."
    end
    redirect_to team_topics_path(@team)
  end

  def close
    return redirect_to team_topics_path(@team), notice: "#{@topic.title} topic is already closed." if @topic.closed?

    return redirect_to team_topics_path(@team), alert: 'You cannot close the Main Chat.' if @topic.main

    if @topic.close
      flash[:success] = "#{@topic.title} topic was successfully closed."
    else
      flash[:error] = "#{@topic.title} topic could not be closed."
    end
    redirect_to team_topics_path(@team)
  end

  def reopen
    return redirect_to team_topics_path(@team), notice: "#{@topic.title} topic is already open." if @topic.open?

    if @topic.reopen
      flash[:success] = "#{@topic.title} topic was successfully reopened."
    else
      flash[:error] = "#{@topic.title} topic could not be reopened."
    end
    redirect_to team_topics_path(@team)
  end

  def favorite
    return redirect_to team_topics_path(@team), alert: 'You cannot favorite a closed topic.' if @topic.closed?

    user_topic = current_user.user_topics.find_or_create_by(topic: @topic)

    if user_topic.favorite!
      flash[:success] = "#{@topic.title} topic favorited."
    else
      flash[:error] = "#{@topic.title} topic could not be favorited."
    end
    redirect_to team_topics_path(@team)
  end

  def unfavorite
    user_topic = current_user.user_topics.find_by(topic: @topic)

    if user_topic&.unfavorite!
      flash[:success] = "#{@topic.title} topic unfavorited."
    else
      flash[:error] = "#{@topic.title} topic could not be unfavorited."
    end
    redirect_to team_topics_path(@team)
  end

  def update_last_read
    user_topic = current_user.user_topics.find_or_create_by(topic: @topic)
    user_topic.update_last_read

    head :ok
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

  def sort_topics(topics) = topics.sort_by { _1.last_message&.created_at || _1.created_at }.reverse
end
