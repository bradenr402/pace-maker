class Topic < ApplicationRecord
  # Associations
  belongs_to :team
  has_many :messages, dependent: :destroy
  has_many :user_topics, dependent: :destroy
  has_many :users, through: :user_topics

  # Validations
  validates :title, presence: true, uniqueness: { scope: :team_id }
  validates :main, inclusion: { in: [true, false] }
  validate :only_one_main_topic

  # Callbacks
  after_create :create_user_topics

  # Scopes
  scope :open, -> { where(closed_at: nil, main: false) }
  scope :closed, -> { where.not(closed_at: nil).where(main: false) }

  # Methods
  def close = update(closed_at: Time.current)

  def closed? = closed_at.present?

  def open? = !closed?

  def reopen = update(closed_at: nil)
  alias open reopen

  def pinned_message = messages.find_by(pinned: true)

  def last_message = messages.where(deleted_at: nil).order(created_at: :desc).limit(1).first

  def favorited_by?(user) = user_topics.exists?(user:, favorited: true)

  def unread_count_for(user) = user_topics.find_by(user:)&.unread_count

  def broadcast_typing_indicator(user, typing = false)
    team.members.each do |member|
      next if member == user

      if typing

        broadcast_append_to(
          "user_#{member.id}_topic_#{id}",
          target: "typing_indicators_#{id}",
          partial: 'typing/indicator',
          locals: { user: user }
        )
      else
        broadcast_remove_to(
          "user_#{member.id}_topic_#{id}",
          target: "typing_user_#{user.id}",
          partial: 'typing/indicator'
        )
      end
    end
  end

  private

  def only_one_main_topic
    return unless main && team.topics.where(main: true).where.not(id:).exists?

    errors.add(:main, 'There can only be one main topic per team')
  end

  def create_user_topics = team.members.each { |user| user_topics.find_or_create_by(user:) }
end
