class Message < ApplicationRecord
  # Includes
  include ActionView::Helpers::SanitizeHelper

  # Associations
  belongs_to :user, optional: true
  belongs_to :topic
  belongs_to :parent, class_name: 'Message', optional: true, counter_cache: :reply_count
  has_many :replies, class_name: 'Message', foreign_key: :parent_id, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  # Callbacks
  before_update :decrement_parent_reply_count, if: -> { deleted_at_changed? && deleted_at.present? }
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update, unless: -> { deleted_at.present? }
  after_update_commit :broadcast_replies
  after_update_commit :broadcast_deleted, if: -> { deleted_at_changed? && deleted_at.present? }

  # Validations
  validates :content, presence: true, unless: -> { deleted_at.present? }

  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :pinned, -> { where(pinned: true) }

  # Methods
  def deleted? = deleted_at.present?

  def deletable? = created_at.after?(15.minutes.ago) && topic.open?

  def editable? = created_at.after?(60.minutes.ago) && topic.open? && (!pinned? || user.owns?(team))

  def unpin! = update!(pinned: false)

  def pin!
    transaction do
      topic.pinned_message&.update(pinned: false)
      update(pinned: true)
    end
  end

  def replies = topic.messages.where(parent_id: id, deleted_at: nil)

  def author_name = user&.default_name || 'Deleted User'

  def team = topic.team

  def self.deleted_text = 'This message was deleted'

  private

  def decrement_parent_reply_count
    parent&.decrement!(:reply_count)
  end

  def broadcast_create
    topic.team.members.each do |member|
      broadcast_append_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: 'messages',
        locals: { message: self, current_user: member }
      )

      next unless parent.present?

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "replies_message_#{parent.id}",
        partial: 'messages/reply_button',
        locals: { message: parent, current_user: member }
      )

      next unless parent.pinned?

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "pinned_replies_message_#{parent.id}",
        partial: 'messages/reply_button',
        locals: { message: parent, pinned: true, current_user: member }
      )
    end
  end

  def broadcast_update
    topic.team.members.each do |member|
      next if member == user

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "message_#{id}",
        locals: { message: self, current_user: member }
      )

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: 'pinned_message',
        partial: 'messages/pinned_message',
        locals: { message: self, current_user: member }
      )
    end
  end

  def broadcast_replies
    return unless replies.any?

    topic.team.members.each do |member|
      replies.each do |reply|
        broadcast_replace_to(
          "user_#{member.id}_topic_#{topic.id}",
          target: "message_#{reply.id}",
          locals: { message: reply, current_user: member }
        )
      end
    end
  end

  def broadcast_deleted
    topic.team.members.each do |member|
      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "message_#{id}",
        partial: 'messages/deleted_message',
        locals: { message: self, current_user: member }
      )

      next unless parent.present?

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "replies_message_#{parent.id}",
        partial: 'messages/reply_button',
        locals: { message: parent, current_user: member }
      )

      next unless parent.pinned?

      broadcast_replace_to(
        "user_#{member.id}_topic_#{topic.id}",
        target: "pinned_replies_message_#{parent.id}",
        partial: 'messages/reply_button',
        locals: { message: parent, pinned: true, current_user: member }
      )
    end
  end
end
