class RunsController < ApplicationController
  before_action :set_run, only: %i[show details edit update destroy enable_comments disable_comments]
  before_action :authenticate_user!
  before_action :authorize_owner!, only: %i[edit update destroy enable_comments disable_comments]

  def show
    add_breadcrumb @run.user.default_name, user_path(@run.user)
    add_breadcrumb 'Runs', user_path(@run.user, tab: 'runsTab')
    add_breadcrumb "#{@run.distance} mi run by #{@run.user.default_name}", run_path(@run)

    @comments = @run.comments.active
                    .order(created_at: :desc)
                    .limit(10)
                    .includes(:user, :likes, { comments: [:user, :likes, { comments: %i[user likes] }] })

    @oldest_timestamp = @comments.last&.created_at
    @more_comments = @run.comments.where('created_at < ?', @oldest_timestamp).exists?
  end

  def details
    add_breadcrumb @run.user.default_name, user_path(@run.user)
    add_breadcrumb 'Runs', user_path(@run.user, tab: 'runsTab')
    add_breadcrumb "#{@run.distance} mi run by #{@run.user.default_name}", run_path(@run)
    add_breadcrumb 'Run Details', run_details_path(@run)

    @likes = @run.likes.includes(:user).where.not(user: nil)
  end

  def new
    add_breadcrumb 'New Run', new_run_path

    @run = current_user.runs.new
  end

  def create
    @run = current_user.runs.build(run_params)
    @run.duration = parse_duration(params[:run][:duration_input]) if params[:run][:duration_input].present?

    if @run.save
      respond_to do |format|
        format.turbo_stream do
          flash.now[:success] = 'Run was successfully created.'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash'),
            turbo_stream.replace('run_modal', partial: 'runs/form_modal',
                                              locals: { run: Run.new, modal_style_buttons: true })
          ]
        end
        format.html { redirect_to @run, success: 'Run was successfully created.' }
      end
    else
      render :new,
             status: :unprocessable_entity,
             error: 'Run could not be created.'

      respond_to do |format|
        format.turbo_stream do
          flash.now[:error] = 'Run could not be created.'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash'),
            turbo_stream.replace('run_modal', partial: 'runs/form_modal',
                                              locals: { run: @run, modal_style_buttons: true })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    add_breadcrumb @run.user.default_name, user_path(@run.user)
    add_breadcrumb 'Runs', user_path(@run.user, tab: 'runsTab')
    add_breadcrumb "#{@run.distance} mi run by #{@run.user.default_name}", run_path(@run)
    add_breadcrumb 'Edit Run', edit_run_path(@run)
  end

  def update
    @run.duration = parse_duration(params[:run][:duration_input]) if params[:run][:duration_input].present?

    if @run.update(run_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:success] = 'Run was successfully updated.'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash'),
            turbo_stream.replace(
              'run_modal',
              partial: 'runs/form_modal',
              locals: { run: @run, modal_style_buttons: true }
            ),
            turbo_stream.replace(
              "turbo_run_#{@run.id}",
              partial: 'runs/turbo_run',
              locals: { run: @run, details_view: true }
            ),

            turbo_stream.replace(
              'locked_comments_notice',
              partial: 'runs/locked_comments_notice',
              locals: { locked: !@run.allow_comments? }
            )
          ]
        end
        format.html { redirect_to @run, success: 'Run was successfully updated.' }
      end
    else
      render :new,
             status: :unprocessable_entity,
             error: 'Run could not be updated.'

      respond_to do |format|
        format.turbo_stream do
          flash.now[:error] = 'Run could not be updated.'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash'),
            turbo_stream.replace(
              'run_modal',
              partial: 'runs/form_modal',
              locals: { run: @run, modal_style_buttons: true }
            ),
            turbo_stream.replace("turbo_run_#{@run.id}", partial: 'runs/turbo_run', locals: { run: @run })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity, error: 'Run could not be updated.' }
      end
    end
  end

  def destroy
    if @run.destroy
      redirect_back fallback_location: root_path, success: 'Run was successfully deleted.'
    else
      redirect_back fallback_location: root_path, error: 'Unable to delete run.'
    end
  end

  def enable_comments
    if @run.update(allow_comments: true)
      flash[:success] = 'Comments have been enabled.'
    else
      flash[:error] = 'Comments could not be enabled.'
    end

    redirect_back fallback_location: root_path
  end

  def disable_comments
    if @run.update(allow_comments: false)
      flash[:success] = 'Comments have been disabled.'
    else
      flash[:error] = 'Comments could not be disabled.'
    end

    redirect_back fallback_location: root_path
  end

  private

  def set_run = @run = Run.find(params[:id])

  def run_params =
    params.require(:run).permit(
      :distance,
      :duration,
      :date,
      :notes,
      :duration_input,
      :allow_comments
    )

  def authorize_owner!
    run = Run.find(params[:id])
    return if current_user == run.user

    redirect_to run, alert: 'You are not authorized to perform this action.'
  end

  def parse_duration(input)
    return nil if input.blank?

    ActiveSupport::Duration.build input.to_i
  end
end
