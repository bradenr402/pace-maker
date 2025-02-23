class Like < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: :like_count

  # Validations
  validates :user_id, uniqueness: { scope: %i[likeable_id likeable_type] }
end
