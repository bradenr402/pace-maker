namespace :strava do
  desc 'Fix run dates by reimporting Strava runs for all users'
  task fix_run_dates: :environment do
    batch_size = ENV.fetch('BATCH_SIZE', 50).to_i

    User.where.not(strava_uid: nil, strava_access_token: nil).find_in_batches(batch_size:) do |users|
      users.each do |user|
        Rails.logger.info("Reimporting runs for user #{user.id}...")
        user.strava_runs.find_each do |run|
          StravaService.import_single_run(user, run.strava_id)
        rescue StandardError => e
          Rails.logger.error("Failed to reimport run #{run.strava_id} for user #{user.id}: #{e.message}")
        end
      end
    end
  end
end
