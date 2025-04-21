require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @team = teams(:one)
    @event = events(:one)
  end

  test 'is valid with valid attributes' do
    assert @event.valid?
  end

  test 'is invalid without a title' do
    @event.title = ''
    assert_not @event.valid?
    assert_includes @event.errors[:title], "can't be blank"
  end

  test 'is invalid if end_date is before start_date' do
    @event.end_date = @event.start_date - 1.day
    assert_not @event.valid?
    assert_includes @event.errors[:end_date], 'must be after the start date'
  end

  test 'link is normalized by stripping whitespace' do
    @event.update!(link: '  https://example.com  ')
    assert_equal 'https://example.com', @event.reload.link
  end

  test "status returns 'upcoming' for future events" do
    @event.start_date = Date.tomorrow
    assert_equal 'upcoming', @event.status
  end

  test "status returns 'current' for current events" do
    @event.start_date = Date.current - 1.day
    @event.end_date = Date.current + 1.day
    assert_equal 'current', @event.status
  end

  test "status returns 'past' for past events" do
    @event.start_date = 3.days.ago
    @event.end_date = 1.day.ago
    assert_equal 'past', @event.status
  end

  test 'days_until_start returns correct value for future events' do
    @event.start_date = Date.current + 3
    assert_equal 3, @event.days_until_start
  end

  test 'days_until_start returns nil for past events' do
    @event.start_date = 2.days.ago
    assert_nil @event.days_until_start
  end

  test 'days_since_end returns correct value for past events' do
    @event.end_date = 2.days.ago
    assert_equal 2, @event.days_since_end
  end

  test 'days_since_end returns nil for future events' do
    @event.end_date = 2.days.from_now
    assert_nil @event.days_since_end
  end
end
