class Run < ApplicationRecord
  belongs_to :user

  validates :distance, :time, :date, presence: true
end
