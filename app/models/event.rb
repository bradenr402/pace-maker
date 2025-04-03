class Event < ApplicationRecord
  # Associations
  belongs_to :team
  has_one_attached :photo

  # Attributes
  attr_accessor :remove_photo

  # Callbacks
  before_save :purge_photo, if: -> { remove_photo == '1' }

  # Normalizations
  normalizes :link, with: ->(link) { link&.strip }
  # TODO: normalizes :link, &:strip

  # Validations
  validates :title, presence: true
  validates :description, length: { maximum: 2000 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validates :link, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

  # Scopes
  scope :upcoming, -> { where('start_date > ?', Date.current) }
  scope :current, -> { where('? BETWEEN start_date AND end_date', Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }
  scope :starting_soon, -> { where(start_date: Date.current..7.days.from_now) }

  # Methods
  def upcoming? = start_date.after? Date.current

  def current? = Date.current.in?(start_date..end_date)

  def past? = end_date.before? Date.current

  def days_until_start
    return nil if start_date.before?(Date.current)

    (start_date - Date.current).to_i
  end

  def days_since_end
    return nil if end_date.after?(Date.current)

    (Date.current - end_date).to_i
  end

  def status
    return 'upcoming' if upcoming?
    return 'past' if past?

    'current'
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, 'must be after the start date') if end_date < start_date
  end

  def purge_photo
    photo.purge_later
  end
end
