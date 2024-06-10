class RunsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_run, only: %i[show edit update destroy]

  def index
    @runs = current_user.runs.order(created_at: :desc)
  end

  def show
  end

  def new
    @run = current_user.runs.new
  end

  def create
    @run = current_user.runs.build(run_params)
    if @run.save
      redirect_to @run, notice: 'Run was successfully logged.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @run.update(run_params)
      redirect_to @run, notice: 'Run was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @run.destroy
    redirect_to runs_url, notice: 'Run was successfully deleted.'
  end

  private

  def set_run
    @run = Runs.find(params[:id])
  end

  def run_params
    params.require(:run).permit(:distance, :time, :date, :comments)
  end
end
