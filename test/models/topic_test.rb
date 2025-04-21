require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  def setup
    @team = teams(:one)
    @user = users(:one)
    @topic = topics(:one)
    @team.team_memberships.build(user: @user)
  end

  test 'should be valid with valid attributes' do
    assert @topic.valid?
  end

  test 'should require a title' do
    @topic.title = nil
    assert_not @topic.valid?
    assert_includes @topic.errors[:title], "can't be blank"
  end

  test 'should enforce uniqueness of title scoped to team' do
    duplicate_topic = @topic.dup
    assert_not duplicate_topic.valid?
  end

  test 'should validate inclusion of main in [true, false]' do
    @topic.main = nil
    assert_not @topic.valid?
  end

  test 'should not allow more than one main topic per team' do
    Topic.create!(title: 'Main Topic', team: @team, main: true)
    another_main = Topic.new(title: 'Another Main', team: @team, main: true)
    assert_not another_main.valid?
    assert_includes another_main.errors[:main], 'There can only be one main topic per team'
  end

  test 'should create user_topics after create' do
    topic = Topic.create!(title: 'Another Topic', team: @team, main: false)
    assert_equal @team.members.count, topic.user_topics.count
  end

  test 'should return true when topic is open' do
    assert @topic.open?
  end

  test 'should return true when topic is closed' do
    @topic.closed_at = Time.current
    assert @topic.closed?
  end

  test 'reopen should set closed_at to nil' do
    @topic.closed_at = Time.current
    @topic.reopen
    assert_nil @topic.closed_at
  end

  test 'favorited_by? should return true if user favorited the topic' do
    ut = @topic.user_topics.find_by(user: @user)
    ut.update!(favorited: true)
    assert @topic.favorited_by?(@user)
  end

  test 'unread_count_for should update when a new message is created' do
    new_topic = Topic.create!(title: 'Empty Topic', team: @team, main: false)
    user_topic = new_topic.user_topics.find_by(user: @user)
    assert_equal 0, user_topic.unread_count

    new_topic.messages.create!(content: 'New message', user: @user)
    user_topic.reload
    assert_equal 1, user_topic.unread_count
  end

  test 'pinned_message should return nil for a new empty topic' do
    new_topic = Topic.create!(title: 'Empty Topic', team: @team, main: false)
    assert_nil new_topic.pinned_message
  end

  test 'last_message should return nil for a new empty topic' do
    new_topic = Topic.create!(title: 'Empty Topic', team: @team, main: false)
    assert_nil new_topic.last_message
  end

  test 'favorited_by? should return false for a new empty topic' do
    new_topic = Topic.create!(title: 'Empty Topic', team: @team, main: false)
    assert_not new_topic.favorited_by?(@user)
  end
end
