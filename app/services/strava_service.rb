class StravaService
  require 'faraday'
  require 'net/http'
  require 'uri'
  require 'rest-client'

  STRAVA_API_BASE = 'https://www.strava.com/api/v3'

  def self.import_runs(user)
    activities = fetch_activities(user)
    activities.each do |activity|
      next unless activity['type'] == 'Run'

      run = user.runs.find_or_initialize_by(strava_id: activity['id'])
      run.date = Date.parse(activity['start_date'])
      run.distance = meters_to_miles(activity['distance'])
      run.duration = ActiveSupport::Duration.build(activity['moving_time'])
      run.comments = activity['description']
      run.strava_id = activity['id']
      run.strava_url = "https://www.strava.com/activities/#{activity['id']}"
      run.save!
    end
  end

  def self.import_single_run(user, activity_id)
    activity = fetch_activity(user, activity_id)
    return unless activity && activity['type'] == 'Run'

    run = user.runs.find_or_initialize_by(strava_id: activity['id'])
    run.date = Date.parse(activity['start_date'])
    run.distance = meters_to_miles(activity['distance'])
    run.duration = ActiveSupport::Duration.build(activity['moving_time'])
    run.comments = activity['description']
    run.strava_id = activity['id']
    run.strava_url = "https://www.strava.com/activities/#{activity['id']}"
    run.save!
  end

  def self.update_run(user, activity_id)
    import_single_run(user, activity_id)
  end

  def self.delete_run(user, activity_id)
    run = user.runs.find_by(strava_id: activity_id)
    run&.destroy!
  end

  def self.fetch_activities(user)
    activities = []
    url = "#{STRAVA_API_BASE}/athlete/activities"
    params = { per_page: 100, page: 1 }

    loop do
      activities.concat(fetch_activities_page(user, url, params))
      break if activities.last(100).size < 100

      params[:page] += 1
    end

    activities
  end

  def self.fetch_activities_page(user, url, params)
    response = RestClient.get(url, { params: params }.merge(headers(user)))
    JSON.parse(response.body)
  rescue RestClient::TooManyRequests => e
    sleep_time = e.response.headers[:retry_after].to_i
    sleep_time = 60 if sleep_time.zero?
    sleep(sleep_time)
    []
  end

  def self.fetch_activity(user, activity_id)
    url = "#{STRAVA_API_BASE}/activities/#{activity_id}"
    response = RestClient.get(url, headers(user))
    JSON.parse(response.body)
  rescue RestClient::NotFound
    nil
  end

  def self.headers(user)
    { Authorization: "Bearer #{user.strava_access_token}" }
  end

  def self.meters_to_miles(meters)
    (meters / 1609.34).round(2)
  end

  def self.create_global_webhook_subscription
    callback_url = 'https://pace-maker.onrender.com/webhooks/strava'
    existing_subscription = StravaWebhookSubscription.find_by(callback_url:)

    return if existing_subscription

    url = "#{STRAVA_API_BASE}/push_subscriptions"

    params = {
      client_id: Rails.application.credentials[:strava_client_id],
      client_secret: Rails.application.credentials[:strava_client_secret],
      callback_url: callback_url,
      verify_token: Rails.application.credentials[:strava_webhook_secret],
      async: true
    }

    Rails.logger.info "Request parameters: #{params}"

    begin
      response = RestClient.post(url, params)
      Rails.logger.info("Strava Webhook subscription response: #{response.body}")

      raise "Unexpected response code: #{response.code}, Response: #{response.body}" unless response.code == 201

      subscription_data = JSON.parse(response.body)
      StravaWebhookSubscription.create!(
        subscription_id: subscription_data['id'],
        callback_url: callback_url
      )

      Rails.logger.info('Webhook subscription created successfully')
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("Strava Webhook subscription failed with response code #{e.response.code}: #{e.response.body}")
    rescue JSON::ParserError => e
      Rails.logger.error("Error parsing Strava Webhook subscription response: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("Error creating Strava Webhook subscription: #{e.message}")
    end
  end
end
