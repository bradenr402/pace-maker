class RunsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_run, only: %i[show edit update destroy]

  def show
    add_breadcrumb @run.user.default_name, user_path(@run.user)
    add_breadcrumb 'Runs', user_path(@run.user, tab: 'runsTab')
    add_breadcrumb "#{@run.distance} mi run by #{@run.user.default_name}", run_path(@run)
  end

  def new
    add_breadcrumb 'New run', new_run_path

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
    add_breadcrumb "Runs by #{@run.user.default_name}", user_path(@run.user, tab: 'runsTab')
    add_breadcrumb "#{@run.distance} mi run by #{@run.user.default_name}", run_path(@run)
    add_breadcrumb 'Edit run', edit_run_path(@run)
  end

  def update
    @run.duration = parse_duration(params[:run][:duration_input]) if params[:run][:duration_input].present?

    if @run.update(run_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:success] = 'Run was successfully updated.'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash'),
            turbo_stream.replace('run_modal', partial: 'runs/form_modal',
                                              locals: { run: @run, modal_style_buttons: true }),
            turbo_stream.replace("turbo_run_#{@run.id}", partial: 'runs/turbo_run', locals: { run: @run })
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
          flash.now[:error] = 'Run could not be updated.'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash'),
            turbo_stream.replace('run_modal', partial: 'runs/form_modal',
                                              locals: { run: @run, modal_style_buttons: true }),
            turbo_stream.replace("turbo_run_#{@run.id}", partial: 'runs/turbo_run', locals: { run: @run })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity, error: 'Run could not be updated.' }
      end
    end
  end

  def destroy
    if @run.destroy
      redirect_to root_path, success: 'Run was successfully deleted.'
    else
      redirect_back fallback_location: root_path, error: 'Unable to delete run.'
    end
  end

  private

  def set_run = @run = Run.find(params[:id])

  def run_params =
    params.require(:run).permit(
      :distance,
      :duration,
      :date,
      :comments,
      :duration_input
    )

  def parse_duration(input)
    parts = input.split(':').map(&:to_i)
    case parts.length
    when 2
      minutes, seconds = parts
      ActiveRecord::Base
        .connection
        .execute("SELECT '#{minutes} minutes #{seconds} seconds'::interval")
        .first[
        'interval'
      ]
    when 3
      hours, minutes, seconds = parts
      ActiveRecord::Base
        .connection
        .execute(
          "SELECT '#{hours} hours #{minutes} minutes #{seconds} seconds'::interval"
        )
        .first[
        'interval'
      ]
    end
  end
end
