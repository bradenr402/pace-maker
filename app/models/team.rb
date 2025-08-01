class Team < ApplicationRecord
  # Concerns
  include TeamCalculations
  include TeamSettings
  include TeamUsersConcern
  include TeamRunsConcern

  # Associations
  belongs_to :owner, class_name: 'User'
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user
  has_many :join_requests,
           foreign_key: 'team_id',
           class_name: 'TeamJoinRequest',
           dependent: :destroy
  has_one_attached :photo
  has_many :team_audits, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :events, dependent: :destroy

  # Callbacks
  before_validation :convert_empty_string_season_dates_to_nil
  after_update :track_changes
  after_create :create_main_chat_topic

  # Validations
  validates :name, presence: true
  validates :owner, presence: true
  validates :description, length: { maximum: 500 }
  validates :season_end_date,
            comparison: {
              greater_than: :season_start_date
            },
            if: -> { season_dates? }
  validate :season_dates_presence_or_absence
  validates :mileage_goal,
            numericality: {
              greater_than_or_equal_to: 0
            },
            if: -> { mileage_goal? }
  validates :long_run_goal,
            numericality: {
              greater_than_or_equal_to: 0
            },
            if: -> { long_run_goal? }

  # Scopes
  scope :not_included_in, ->(team_ids) { where.not(id: team_ids) }
  scope :by_connected_users, ->(user) { where(user_id: user.connected_user_ids) }
  scope :updated_recently, ->(since = 1.week.ago) { where('teams.updated_at >= ?', since) }
  scope :recently_created, ->(since = 1.week.ago) { where('teams.created_at >= ?', since) }

  # Methods
  def season_dates? = season_start_date.present? && season_end_date.present?

  def season_in_progress? = season_start_date&.past? && season_end_date&.future?

  def season_over? = season_end_date&.past?

  def season_not_started_yet? = season_start_date&.future?

  def season_range = season_start_date..season_end_date

  def events_on_date(date) = events.where(start_date: ..date, end_date: date..)

  def event_on_date?(date) = events_on_date(date).exists?

  def filtered_members
    member_ids = team_memberships.where(included_in_stats: true).map(&:user_id)
    User.where(id: member_ids)
  end

  def main_chat_topic = topics.find_by(main: true)

  def main_chat_messages = main_chat_topic.messages

  private

  def season_dates_presence_or_absence
    return if season_dates? || season_start_date.blank? && season_end_date.blank?

    errors.add(:base, 'Season start and end dates must both be present or both be absent')
  end

  def convert_empty_string_season_dates_to_nil
    self.season_start_date = nil if season_start_date == ''
    self.season_end_date = nil if season_end_date == ''
  end

  def track_changes
    saved_changes.each do |attribute, (old_value, new_value)|
      next if attribute == 'updated_at'

      team_audits.create!(
        attribute_name: attribute,
        old_value:,
        new_value:,
        changed_at: Time.current
      )
    end

    # rubocop:disable Style/HashEachMethods
    TeamSettings.keys.each do |key|
      settings(key).saved_changes.each do |attribute, (old_value, new_value)|
        next if attribute == 'updated_at'

        team_audits.create!(
          attribute_name: "settings_#{attribute}",
          old_value:,
          new_value:,
          changed_at: Time.current
        )
      end
    end
    # rubocop:enable Style/HashEachMethods
  end

  def create_main_chat_topic
    topics.create!(title: 'Main Chat', main: true)
  end
end
