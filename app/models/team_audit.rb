class TeamAudit < ApplicationRecord
  belongs_to :team

  def attribute_key
    key = attribute_name.gsub('_setting', '')

    key.to_sym
  end
end
