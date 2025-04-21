require 'test_helper'

class TeamJoinRequestTest < ActiveSupport::TestCase
  setup do
    @user = users(:two)
    @team = teams(:one)
    @request = TeamJoinRequest.new(user: @user, team: @team)
  end

  test 'should be valid with valid attributes' do
    assert @request.valid?
  end

  test 'should not allow duplicate join requests for the same team' do
    @request.save!
    duplicate = TeamJoinRequest.new(user: @user, team: @team)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], 'has already sent a join request'
  end

  test 'should be blocked if rejected and request number exceeds max allowed' do
    @request.rejected!
    @request.request_number = @team.max_allowed_requests
    assert @request.blocked?
  end

  test 'should not be allowed if blocked' do
    @request.request_number = @team.max_allowed_requests
    assert_not @request.allowed?
  end

  test 'should not be allowed if user is already pending' do
    @request.status = :pending
    assert_not @request.allowed?
  end

  test 'should not be allowed if user is already approved' do
    @request.approved!
    assert_not @request.allowed?
  end

  test 'should not be allowed if user is already a member' do
    @team.team_memberships.build(user: @user)
    assert_not @request.allowed?
  end

  test 'should not be allowed if user owns the team' do
    @team.owner = @user
    assert_not @request.allowed?
  end
end
