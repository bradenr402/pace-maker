class FeedbackFormController < ApplicationController
  before_action :authenticate_user!

  def create
    user_data = {
      id: current_user.id,
      email: current_user.email,
      username: current_user.username,
      display_name: current_user.display_name
    }

    feedback_data = {
      feedback_type: feedback_params[:feedback_type],
      title: feedback_params[:title],
      message: feedback_params[:message],
      images: feedback_params[:images],
      video: feedback_params[:video]
    }

    # Send the feedback email
    FeedbackMailer.with(
      feedback: feedback_data,
      user: user_data
    ).feedback_notification.deliver_later

    redirect_back fallback_location: root_path,
                  notice: 'Your feedback has been received.',
                  success: 'Thank you for your feedback!'
  end

  private

  def feedback_params =
    params.require(:feedback_form).permit(:feedback_type, :title, :message, images: [], video: [])
end
