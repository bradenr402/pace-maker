require 'test_helper'

class TeamMembershipTest < ActiveSupport::TestCase
  def setup
    @user = users(:two)
    @team = teams(:one)
    @existing_membership = team_memberships(:one)
  end

  test 'valid team membership' do
    membership = TeamMembership.new(user: @user, team: @team)

    assert membership.valid?
  end

  test 'invalid without user' do
    membership = TeamMembership.new(team: @team)

    assert_not membership.valid?
    assert_includes membership.errors[:user], 'must exist'
  end

  test 'invalid without team' do
    membership = TeamMembership.new(user: @user)

    assert_not membership.valid?
  end

  test 'enforces uniqueness of user scoped to team' do
    duplicate = TeamMembership.new(user: @existing_membership.user, team: @existing_membership.team)

    assert_not duplicate.valid?
  end
end
