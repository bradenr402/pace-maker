require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @message = messages(:one)
    @run = runs(:one)
    @comment = comments(:one)
  end

  test 'valid like with user and likeable (message)' do
    like = Like.new(user: @user, likeable: @message)
    assert like.valid?
  end

  test 'valid like with user and likeable (run)' do
    like = Like.new(user: @user, likeable: @run)
    assert like.valid?
  end

  test 'valid like with user and likeable (comment)' do
    like = Like.new(user: @user, likeable: @comment)
    assert like.valid?
  end

  test 'invalid without user' do
    like = Like.new(likeable: @message)
    assert_not like.valid?
    assert_includes like.errors[:user], 'must exist'
  end

  test 'invalid without likeable' do
    like = Like.new(user: @user)
    assert_not like.valid?
    assert_includes like.errors[:likeable], 'must exist'
  end

  test 'invalid if duplicate like exists for same user and likeable (message)' do
    Like.create!(user: @user, likeable: @message)
    duplicate = Like.new(user: @user, likeable: @message)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], 'has already been taken'
  end

  test 'invalid if duplicate like exists for same user and likeable (run)' do
    Like.create!(user: @user, likeable: @run)
    duplicate = Like.new(user: @user, likeable: @run)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], 'has already been taken'
  end

  test 'invalid if duplicate like exists for same user and likeable (comment)' do
    Like.create!(user: @user, likeable: @comment)
    duplicate = Like.new(user: @user, likeable: @comment)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], 'has already been taken'
  end

  test 'like_count is updated on create and destroy (message)' do
    like = Like.new(user: @user, likeable: @message)

    assert_difference 'Like.count', 1 do
      like.save!
    end

    assert_difference 'Like.count', -1 do
      like.destroy
    end
  end

  test 'like_count is updated on create and destroy (run)' do
    like = Like.new(user: @user, likeable: @run)

    assert_difference 'Like.count', 1 do
      like.save!
    end

    assert_difference 'Like.count', -1 do
      like.destroy
    end
  end

  test 'like_count is updated on create and destroy (comment)' do
    like = Like.new(user: @user, likeable: @comment)

    assert_difference 'Like.count', 1 do
      like.save!
    end

    assert_difference 'Like.count', -1 do
      like.destroy
    end
  end
end
