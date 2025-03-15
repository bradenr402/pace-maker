class Comment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: :reply_count
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  # Callbacks
  before_update :decrement_parent_reply_count, if: -> { deleted_at_changed? && deleted_at.present? }

  # Scopes
  scope :active, -> { where(deleted_at: nil) }

  # Validations
  validates :content, presence: true
  validates :commentable_id, presence: true

  # Methods
  def deleted? = deleted_at.present?

  def deletable? = created_at.after?(15.minutes.ago)

  def soft_delete = update(content: Comment.deleted_text, deleted_at: Time.current)

  def editable? = created_at.after?(15.minutes.ago) && (parent_run.allow_comments? || parent_run.user == user)

  def replies
    comment_ids = comments.select { |comment| comment.comments.exists? || !comment.deleted? }.pluck(:id)
    comments.where(id: comment_ids)
  end

  def author_name = user&.default_name || 'Deleted User'

  def parent_comment = (commentable if commentable.is_a? Comment)

  def top_comment
    comment = commentable
    comment = comment.commentable until comment.commentable == comment.parent_run
    comment
  end

  def parent_run
    run = commentable
    run = run.commentable until run.is_a? Run
    run
  end

  def level
    parent_comment ? parent_comment.level + 1 : 0
  end

  def self.deleted_text = 'This comment was deleted'

  private

  def decrement_parent_reply_count
    commentable&.decrement!(:reply_count)
  end
end
