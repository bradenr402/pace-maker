class Like < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: :like_count

  # Callbacks
  after_create_commit :broadcast_like_update
  after_destroy_commit :broadcast_like_update

  # Validations
  validates :user_id, uniqueness: { scope: %i[likeable_id likeable_type] }

  private

  def broadcast_like_update
    message = likeable
    topic = message.topic

    topic.team.members.each do |member|
      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "likes_message_#{message.id}",
        partial: 'messages/like_button',
        locals: { message:, current_user: member }
      )

      next unless message.pinned?

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "pinned_likes_message_#{message.id}",
        partial: 'messages/like_button',
        locals: { message:, pinned: true, current_user: member }
      )
    end
  end
end
