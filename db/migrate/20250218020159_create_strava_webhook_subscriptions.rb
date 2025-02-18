class CreateStravaWebhookSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :strava_webhook_subscriptions do |t|
      t.integer :subscription_id
      t.string :callback_url

      t.timestamps
    end
  end
end
