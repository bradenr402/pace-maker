if Rails.env.development?
  Rack::MiniProfiler.config.enabled = false
end
