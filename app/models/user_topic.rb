class UserTopic < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :topic

  # Validations
  validates :user_id, uniqueness: { scope: :topic_id }

  # Methods
  def favorite! = update!(favorited: true)
  def unfavorite! = update!(favorited: false)
end
