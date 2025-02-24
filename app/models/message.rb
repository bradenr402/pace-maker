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
    topic&.pinned_message&.unpin!

    update!(pinned: true)
  end

  def replies = Message.where(parent_id: id, deleted_at: nil)

  def author_name = user&.default_name || 'Deleted User'

  def team = topic.team

  def self.deleted_text = 'This message was deleted'

  private

  def decrement_parent_reply_count
    parent&.decrement!(:reply_count)
  end
end
