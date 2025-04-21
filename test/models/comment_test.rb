require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @run = runs(:one)
    @comment = Comment.create!(user: @user, commentable: @run, content: 'Nice job!')
    @parent = Comment.create!(user: @user, commentable: @run, content: 'Parent')
    @child = Comment.create!(user: @user, commentable: @parent, content: 'Child')
  end

  test 'is valid with valid attributes' do
    assert @comment.valid?
  end

  test 'is invalid without content' do
    @comment.content = nil
    assert_not @comment.valid?
  end

  test 'is invalid without commentable_id' do
    @comment.commentable_id = nil
    assert_not @comment.valid?
  end

  test 'deleted? returns true when deleted_at is set' do
    @comment.update!(deleted_at: Time.current)
    assert @comment.deleted?
  end

  test 'deletable? returns true within 15 minutes' do
    assert @comment.deletable?

    @comment.update!(created_at: 16.minutes.ago)
    assert_not @comment.deletable?
  end

  test 'soft_delete sets content and deleted_at' do
    freeze_time do
      @comment.soft_delete
      assert_equal Comment.deleted_text, @comment.content
      assert_not_nil @comment.deleted_at
    end
  end

  test 'editable? returns true if within 15 minutes and run has comments allowed or if user owns parent run' do
    assert @comment.editable?

    @run.update!(allow_comments: false)
    @comment.update!(user: @other_user)
    assert_not @comment.editable?

    @comment.update!(user: @run.user)
    assert @comment.editable?

    @comment.update!(created_at: 16.minutes.ago)
    assert_not @comment.editable?
  end

  test 'author_name returns default name or fallback' do
    assert_equal @user.default_name, @comment.author_name
    @comment.user = nil
    assert_equal 'Deleted User', @comment.author_name
  end

  test "parent_comment returns commentable if it's a comment" do
    assert_equal @parent, @child.parent_comment
  end

  test 'top_comment returns the top-level comment' do
    assert_equal @parent, @child.top_comment
  end

  test 'parent_run returns the top-level run' do
    assert_equal @run, @child.parent_run
  end

  test 'level returns nesting depth' do
    assert_equal 1, @child.level
  end

  test 'reply_count is updated correctly' do
    assert_equal 1, @parent.reload.reply_count

    @child.soft_delete
    assert_equal 0, @parent.reload.reply_count
  end
end
