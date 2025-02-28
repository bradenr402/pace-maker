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

  def receive
    if params[:object_type] == 'athlete' &&
       params[:aspect_type] == 'update' &&
       params.dig(:updates, :authorized) == 'false'
      user = User.find_by(strava_uid: params[:object_id])
      return render json: { error: 'User not found' }, status: :not_found unless user

      user.delete_strava_data!(true)
      return render json: { status: 'success' }, status: :ok
    end

    # Ensure the event is about an activity and has a valid ID
    unless params[:object_type] == 'activity' && params[:object_id].present?
      return render json: { error: 'Invalid payload' }, status: :bad_request
    end

    user = User.find_by(strava_uid: params[:owner_id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    case params[:aspect_type]
    when 'create'
      unless user.auto_import_strava?
        Rails.logger.info "Received Strava webhook for user #{user.id} but auto-import is disabled"
        return render json: { error: 'User has opted out of automatic imports for new Strava activities' }, status: :ok
      end

      StravaService.import_single_run(user, params[:object_id])
    when 'update'
      StravaService.update_run(user, params[:object_id])
    when 'delete'
      run = user.runs.find_by(strava_id: params[:object_id])

      if run&.destroy
        Rails.logger.info "Deleted Strava run #{params[:object_id]} for user #{user.id}"
      else
        Rails.logger.warn "Failed to delete Strava run #{params[:object_id]} for user #{user.id}: Run not found"
      end
    end

    render json: { status: 'success' }, status: :ok
  end
end
