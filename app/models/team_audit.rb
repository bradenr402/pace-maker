class TeamAudit < ApplicationRecord
  belongs_to :team

  def attribute_key
    key = attribute_name.gsub('_setting', '')

    key.to_sym
  end

  def attr_removed? = old_value.present? && new_value.blank?

  def attr_added? = old_value.blank? && new_value.present?

  alias attribute_added? attr_added?
  alias attribute_removed? attr_removed?

  def attr_is_date? = attribute_name == 'season_start_date' || attribute_name == 'season_end_date'

  def attr_is_description? = attribute_name == 'description'

  def attr_is_mileage_goal? = attribute_name == 'mileage_goal'

  def attr_is_long_run_goal? = attribute_name == 'long_run_goal'
end
