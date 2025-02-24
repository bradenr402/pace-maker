class UserTopic < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :topic

  # Validations
  validates :user_id, uniqueness: { scope: :topic_id }

  # Callbacks
  after_create :update_last_read

  # Methods
  def favorite! = update!(favorited: true)
  def unfavorite! = update!(favorited: false)

  def unread_count = topic.messages.where('created_at > ?', last_read_at).count

  def update_last_read = update(last_read_at: Time.current)
end
