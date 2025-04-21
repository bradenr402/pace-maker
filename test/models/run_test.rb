require 'test_helper'

class RunTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @run = Run.new(
      user: @user,
      date: Date.today,
      distance: 5.0,
      duration: 45.minutes
    )
  end

  test 'should be valid with valid attributes' do
    assert @run.valid?
  end

  test 'should require a date' do
    @run.date = nil
    assert_not @run.valid?
    assert_includes @run.errors[:date], "can't be blank"
  end

  test 'should require a distance' do
    @run.distance = nil
    assert_not @run.valid?
    assert_includes @run.errors[:distance], "can't be blank"
  end

  test 'should not allow negative distance' do
    @run.distance = -1.0
    assert_not @run.valid?
    assert_includes @run.errors[:distance], 'must be greater than or equal to 0'
  end

  test 'should not allow future date unless strava_id is present' do
    @run.date = Date.tomorrow
    assert_not @run.valid?
    assert_includes @run.errors[:date], 'cannot be in the future.'
  end

  test 'should allow future date if strava_id is present' do
    @run.date = Date.tomorrow
    @run.strava_id = '123456'
    assert @run.valid?
  end

  test 'should reject negative duration' do
    @run.duration = -30.minutes
    assert_not @run.valid?
    assert_includes @run.errors[:duration], 'Duration must be positive'
  end

  test 'long_run_for_team? should return true if distance meets team long_run_distance' do
    team = Team.new
    team.settings(:long_runs).long_run_distance_neutral = 4.0
    assert @run.long_run_for_team?(team)
  end

  test 'long_run_for_team? should return false if no team' do
    assert_not @run.long_run_for_team?(nil)
  end

  test 'long_run_for_team? should return false if not a team object' do
    assert_not @run.long_run_for_team?('NotATeam')
  end

  test 'long_run_for_team? should return false if distance too short' do
    @run.distance = 3.0
    team = Team.new
    def long_run_distance_for_user(_user) = 5.0
    assert_not @run.long_run_for_team?(team)
  end

  test 'pace should calculate correctly' do
    expected_pace = (@run.duration / @run.distance).round
    assert_equal expected_pace, @run.pace
  end

  test 'pace should return nil if distance is zero' do
    @run.distance = 0
    assert_nil @run.pace
  end

  test 'pace_per_km should return nil if distance is zero' do
    @run.distance = 0
    assert_nil @run.pace_per_km
  end

  test 'pace should return nil if duration is blank' do
    @run.duration = nil
    assert_nil @run.pace
  end

  test 'pace_per_km should return nil if duration is blank' do
    @run.duration = nil
    assert_nil @run.pace_per_km
  end
end
