class FeedbackMailer < ApplicationMailer
  default to: 'get.pace.maker@gmail.com'

  def feedback_notification
    @feedback = params[:feedback]
    @user = params[:user]

    # Attach files if present
    if @feedback[:images].present?
      @feedback[:images].each do |image|
        next if image.blank?
        attachments[image.original_filename] = image.read
      end
    end

    attachments[@feedback[:video].original_filename] = @feedback[:video].read if @feedback[:video].present?

    mail(
      reply_to: @user[:email],
      subject: "#{@feedback[:feedback_type].titleize} - #{@feedback[:title]}"
    )
  end
end
