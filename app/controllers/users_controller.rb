class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show]

  def show
    add_breadcrumb @user.default_name, user_path(@user)

    @runs, @date_range = get_runs_and_date_range
    @owned_teams = @user.owned_teams.with_attached_photo.includes(:owner)
    @membered_teams = @user.membered_teams.with_attached_photo.includes(:owner)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def profile
    redirect_to user_path(current_user)
  end

  def unlink_google_account
    if current_user.password_changed_at.nil?
      flash[:alert] = 'You must set a password to unlink your Google account.'
    elsif current_user.update(provider: nil, uid: nil, avatar_url: nil)
      flash[:success] = 'Your Google account was unlinked successfully.'
    else
      flash[:error] = 'There was an issue unlinking your Google account.'
    end
    redirect_to edit_user_registration_path
  end

  def unlink_strava_account
    if current_user.deauthorize_strava_account!
      delete_runs = params[:delete_strava_data] == 'true'

      if current_user.delete_strava_data!(delete_runs:)
        flash[:success] = if delete_runs
                            'Your Strava account was successfully disconnected and all your runs from Strava were deleted.'
                          else
                            'Your Strava account was successfully disconnected. Your runs from Strava were not deleted.'
                          end
      end
    else
      flash[:error] = 'There was an issue disconnecting your Strava account.'
    end
    redirect_to edit_user_registration_path
  end

  private

  def set_user = @user = User.with_attached_avatar.find(params[:id])

  def get_runs_and_date_range
    today = Date.today

    if params[:run_date_range].present?
      case params[:run_date_range]
      when 'This week'
        [
          @user.runs_in_date_range(today.beginning_of_week..today),
          'this week'
        ]
      when 'Last week'
        one_week_ago = today - 1.week
        [
          @user.runs_in_date_range(
            one_week_ago.beginning_of_week..one_week_ago.end_of_week
          ),
          'last week'
        ]
      when 'This month'
        [
          @user.runs_in_date_range(today.beginning_of_month..today),
          'this month'
        ]
      when 'Last month'
        one_month_ago = today - 1.month
        [
          @user.runs_in_date_range(
            one_month_ago.beginning_of_month..one_month_ago.end_of_month
          ),
          'last month'
        ]
      when 'Custom range'
        start_date = params[:run_start_date].to_date
        end_date = params[:run_end_date].to_date
        [
          @user.runs_in_date_range(start_date..end_date),
          "between #{start_date.strftime('%m/%d/%Y')} and #{end_date.strftime('%m/%d/%Y')}"
        ]
      end
    else
      [@user.runs_in_date_range(today.beginning_of_week..today), 'this week']
    end
  end
end
