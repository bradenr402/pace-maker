class Run < ApplicationRecord
  include RunCalculations

  belongs_to :user

  validates :date, presence: true
  validates :distance,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }
  validates :duration, presence: true
  validate :date_not_in_future
  validate :duration_requirements

  attr_accessor :duration_input

  scope :in_date_range, ->(range) { where(date: range).order(date: :desc) }
  scope :today, -> { where(date: Date.today.all_day).order(date: :desc) }
  scope :excluding_date, ->(date) { where.not(date: date) }

  private

  def duration_requirements
    return unless duration

    begin
      unless duration.is_a?(ActiveSupport::Duration)
        errors.add(:duration, 'Invalid interval format')
      end
    rescue ArgumentError
      errors.add(:duration, 'Invalid duration format')
    end

    errors.add(:duration, 'Duration must be positive') if duration.negative?
  end

  def date_not_in_future =
    (errors.add(:date, 'cannot be in the future.') if date.future?)
end
