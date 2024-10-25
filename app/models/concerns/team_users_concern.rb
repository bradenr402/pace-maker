module TeamUsersConcern
  extend ActiveSupport::Concern

  def gender_requirement_met?(user) = require_gender? && user.gender?

  def members_in_common(user) =
    members
      .includes(:teams)
      .select do |member|
        member != user && member != owner && (member.teams & user.teams).any?
      end

  def any_members_in_common?(user) = members_in_common(user).any?

  def male_members = members.where(gender: 'male')

  def female_members = members.where(gender: 'female')

  def neutral_gender_members = members.where(gender: '')
end