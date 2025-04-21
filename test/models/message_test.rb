require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  setup do
    @team = teams(:one)
    @topic = topics(:one)
    @user = users(:one)
    @team.team_memberships.build(user: @user)
    @team.owner = @user
    @message = messages(:one)
  end

  test 'should be valid with valid attributes' do
    message = Message.new(content: 'Hello world', topic: @topic, user: @user)
    assert message.valid?
  end

  test 'should be invalid without content' do
    message = Message.new(content: nil, topic: @topic, user: @user)
    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end

  test 'deleted? should return true if deleted_at is present' do
    @message.deleted_at = Time.current
    assert @message.deleted?
  end

  test 'deletable? should be false if message is older than 15 minutes' do
    @message.created_at = 20.minutes.ago
    assert_not @message.deletable?
  end

  test 'soft_delete should set deleted_at and content' do
    travel_to Time.current do
      @message.soft_delete
      assert_equal Message.deleted_text, @message.reload.content
      assert @message.deleted_at.present?
      assert_not @message.pinned?
    end
  end

  test 'editable? returns false if pinned and user does not own team' do
    @message.created_at = 5.minutes.ago
    @message.pinned = true
    assert_not @message.editable?
  end

  test 'pin! should unpin previous pinned message and pin current one' do
    pinned = Message.create!(user: @user, content: 'Old pinned', topic: @topic, pinned: true)
    @message.pin!
    assert_not pinned.reload.pinned?
    assert @message.reload.pinned?
  end

  test 'unpin! should set pinned to false' do
    @message.update(pinned: true)
    @message.unpin!
    assert_not @message.reload.pinned?
  end

  test 'replies should return non-deleted replies' do
    reply = Message.create!(content: 'Reply', topic: @topic, parent: @message, user: @user)
    deleted_reply = Message.create!(content: 'Deleted', topic: @topic, parent: @message, user: @user,
                                    deleted_at: Time.current)
    assert_includes @message.replies, reply
    assert_not_includes @message.replies, deleted_reply
  end

  test 'nested_replies should include all descendant replies' do
    reply = Message.create!(content: 'Reply', topic: @topic, parent: @message, user: @user)
    nested_reply = Message.create!(content: 'Nested', topic: @topic, parent: reply, user: @user)
    assert_includes @message.nested_replies, reply
    assert_includes @message.nested_replies, nested_reply
  end

  test "author_name returns user name or 'Deleted User'" do
    assert_equal @user.default_name, @message.author_name
    @message.user = nil
    assert_equal 'Deleted User', @message.author_name
  end
end
