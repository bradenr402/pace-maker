class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show]

  def index
  end

  def show
    @user = User.find(params[:id])
    today = Date.today

    @runs, @title =
      if params[:run_date_range].present?
        case params[:run_date_range]
        when 'This week'
          [
            @user.runs_in_date_range(today.beginning_of_week..today),
            'Runs This Week'
          ]
        when 'Last week'
          one_week_ago = today - 1.week
          [
            @user.runs_in_date_range(
              one_week_ago.beginning_of_week..one_week_ago.end_of_week
            ),
            'Runs Last Week'
          ]
        when 'This month'
          [
            @user.runs_in_date_range(today.beginning_of_month..today),
            'Runs This Month'
          ]
        when 'Last month'
          one_month_ago = today - 1.month
          [
            @user.runs_in_date_range(
              one_month_ago.beginning_of_month..one_month_ago.end_of_month
            ),
            'Runs Last Month'
          ]
        when 'Custom range'
          start_date = params[:run_start_date].to_date
          end_date = params[:run_end_date].to_date
          [
            @user.runs_in_date_range(start_date..end_date),
            "Runs between #{start_date.strftime('%m/%d/%Y')} and #{end_date.strftime('%m/%d/%Y')}"
          ]
        end
      else
        [
          @user.runs_in_date_range(today.beginning_of_week..today),
          'Runs This Week'
        ]
      end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def profile
    redirect_to current_user
  end

  private

  def set_user = @user = User.find(params[:id])
end
