Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists?('strava_webhook_subscriptions')
    StravaService.create_global_webhook_subscription
  else
    Rails.logger.warn('Strava webhook subscription skipped: table does not exist.')
  end
end
