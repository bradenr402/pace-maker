require 'test_helper'

class UserTopicTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @topic = topics(:one)
    @user_topic = user_topics(:one)
  end

  test 'should be valid with valid attributes' do
    assert @user_topic.valid?
  end

  test 'should not allow duplicate user-topic pair' do
    duplicate = UserTopic.new(user: @user, topic: @topic)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], 'has already been taken'
  end

  test 'should mark as favorited' do
    @user_topic.favorite!
    assert @user_topic.favorited
  end

  test 'should unfavorite' do
    @user_topic.update!(favorited: true)
    @user_topic.unfavorite!
    assert_not @user_topic.favorited
  end
end
