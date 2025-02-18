class StravaWebhookSubscription < ApplicationRecord
  validates :subscription_id, presence: true, uniqueness: true
  validates :callback_url, presence: true
end
