require "sidekiq"

redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Load the cron schedule (sidekiq-cron) only on the server process.
  # The schedule file ships with all entries commented out, so no scraper
  # jobs run until they are explicitly enabled.
  schedule_file = Rails.root.join("config/sidekiq_schedule.yml")
  if File.exist?(schedule_file)
    schedule = YAML.load_file(schedule_file) || {}
    Sidekiq::Cron::Job.load_from_hash(schedule) if schedule.any?
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
