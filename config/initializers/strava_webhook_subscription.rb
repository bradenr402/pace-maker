Rails.application.config.after_initialize do
  StravaService.create_global_webhook_subscription if Rails.env.production?
end
