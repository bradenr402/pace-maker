class StravaWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def verify
    # Step 1: Check that Strava sent the expected challenge parameter
    if params['hub.mode'] == 'subscribe' && params['hub.challenge'].present? && params['hub.verify_token'] == Rails.application.credentials[:strava_webhook_secret]
      # Step 2: Return the challenge token sent by Strava to verify your subscription
      render json: { 'hub.challenge': params['hub.challenge'] }, status: :ok
    else
      # Step 3: Respond with an error if the request is invalid
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def create
    # Check if the request is valid (it has the expected object type and object ID)
    if params[:object_type] == 'activity' && params[:object_id].present?
      user = User.find_by(strava_uid: params[:owner_id])
      return unless user&.auto_import_strava?

      StravaService.import_single_run(user, params[:object_id])

      render json: { status: 'success' }, status: :ok
    else
      render json: { error: 'Invalid payload' }, status: :bad_request
    end
  end
end
