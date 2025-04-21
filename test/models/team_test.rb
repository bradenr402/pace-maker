require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @team = Team.new(name: 'Test Team', owner: @user)
    @team.team_memberships.build(user: @user)
  end

  test 'valid team' do
    assert @team.valid?
  end

  test 'invalid without name' do
    @team.name = nil
    assert_not @team.valid?
    assert_includes @team.errors[:name], "can't be blank"
  end

  test 'invalid without owner' do
    @team.owner = nil
    assert_not @team.valid?
    assert_includes @team.errors[:owner], "can't be blank"
  end

  test 'description cannot be too long' do
    @team.description = 'a' * 501
    assert_not @team.valid?
    assert_includes @team.errors[:description], 'is too long (maximum is 500 characters)'
  end

  test 'season_end_date must be after season_start_date' do
    @team.season_start_date = Date.today
    @team.season_end_date = Date.yesterday
    assert_not @team.valid?
    assert_includes @team.errors[:season_end_date], "must be greater than #{@team.season_start_date}"
  end

  test 'season_dates_presence_or_absence validation' do
    @team.season_start_date = Date.today
    @team.season_end_date = nil
    assert_not @team.valid?
    assert_includes @team.errors[:base], 'Season start and end dates must both be present or both be absent'

    @team.season_start_date = nil
    @team.season_end_date = Date.today
    assert_not @team.valid?
    assert_includes @team.errors[:base], 'Season start and end dates must both be present or both be absent'
  end

  test 'mileage_goal must be non-negative' do
    @team.mileage_goal = -10
    assert_not @team.valid?
    assert_includes @team.errors[:mileage_goal], 'must be greater than or equal to 0'
  end

  test 'long_run_goal must be non-negative' do
    @team.long_run_goal = -10
    assert_not @team.valid?
    assert_includes @team.errors[:long_run_goal], 'must be greater than or equal to 0'
  end

  test 'season_dates? helper returns true if both dates are present' do
    @team.season_start_date = Date.today
    @team.season_end_date = Date.tomorrow
    assert @team.season_dates?
  end

  test 'season_in_progress? returns true when season is active' do
    @team.season_start_date = 1.week.ago
    @team.season_end_date = 1.week.from_now
    assert @team.season_in_progress?
  end

  test 'season_over? returns true when end date is in the past' do
    @team.season_start_date = 2.weeks.ago
    @team.season_end_date = 1.day.ago
    assert @team.season_over?
  end

  test 'season_not_started_yet? returns true when start date is in the future' do
    @team.season_start_date = 1.day.from_now
    @team.season_end_date = 2.days.from_now
    assert @team.season_not_started_yet?
  end

  test 'event_on_date? returns true if event exists on given date' do
    @team.save!
    @team.events.create!(title: 'Test Event', start_date: Date.today, end_date: Date.today)
    assert @team.event_on_date?(Date.today)
  end

  test 'main_chat_topic is created after team is saved' do
    @team.save!
    assert_equal 'Main Chat', @team.main_chat_topic.title
  end

  test 'season_progress calculates correctly' do
    @team.season_start_date = 5.days.ago
    @team.season_end_date = 5.days.from_now
    @team.save!
    assert_in_delta 50.0, @team.season_progress, 0.1
  end

  test 'days_completed_in_season calculates correctly' do
    @team.season_start_date = 5.days.ago
    @team.season_end_date = 5.days.from_now
    @team.save!
    assert_equal 5.0, @team.days_completed_in_season
  end

  test 'days_remaining_in_season calculates correctly' do
    @team.season_start_date = 5.days.ago
    @team.season_end_date = 5.days.from_now
    @team.save!
    assert_equal 5.0, @team.days_remaining_in_season
  end

  test 'total_miles_in_season calculates correctly' do
    @team.season_start_date = 5.days.ago
    @team.season_end_date = 5.days.from_now
    @team.save!
    @user.runs.create!(distance: 5.0, date: Date.today)
    assert_equal 5.0, @team.total_miles_in_season
  end

  test 'mileage_goal_progress calculates correctly' do
    @team.season_start_date = 5.days.ago
    @team.season_end_date = 5.days.from_now
    @team.mileage_goal = 100
    @team.save!
    @user.runs.create!(distance: 50, date: Date.today)
    assert_equal 50.0, @team.mileage_goal_progress
  end

  test 'long_run_goal_progress calculates correctly' do
    @team.season_start_date = 5.days.ago
    @team.season_end_date = 5.days.from_now
    @team.long_run_goal = 10
    @team.save!
    @user.runs.create!(distance: 15, date: Date.today)
    assert_equal 10.0, @team.long_run_goal_progress
  end

  test 'meeting_mileage_goal? returns true when on track' do
    @team.season_start_date = 10.days.ago
    @team.season_end_date = 10.days.from_now
    @team.mileage_goal = 100
    @team.save!
    @user.runs.create!(distance: 50, date: Date.today)
    assert @team.meeting_mileage_goal?
  end

  test 'ahead_of_mileage_goal? returns true when ahead' do
    @team.mileage_goal = 100
    @team.season_start_date = 10.days.ago
    @team.season_end_date = 10.days.from_now
    @team.save!
    @user.runs.create!(distance: 60, date: Date.today)
    assert @team.ahead_of_mileage_goal?
  end

  test 'behind_mileage_goal? returns true when behind' do
    @team.mileage_goal = 100
    @team.season_start_date = 10.days.ago
    @team.season_end_date = 10.days.from_now
    @team.save!
    @user.runs.create!(distance: 40, date: Date.today)
    assert @team.behind_mileage_goal?
  end

  test 'mileage_goal_complete? returns true when goal is met' do
    @team.mileage_goal = 100
    @team.season_start_date = 10.days.ago
    @team.season_end_date = 10.days.from_now
    @team.save!
    @user.runs.create!(distance: 100, date: Date.today)
    assert @team.mileage_goal_complete?
  end

  test 'long_run_goal_complete? returns true when goal is met' do
    @team.long_run_goal = 5
    @team.save!
    5.times do
      @user.runs.create!(distance: 10, date: Date.today)
    end
    assert @team.long_run_goal_complete?
  end
end
